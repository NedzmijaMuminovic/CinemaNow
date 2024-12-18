﻿using CinemaNow.Models;
using CinemaNow.Models.SearchObjects;
using CinemaNow.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Linq.Dynamic.Core;
using CinemaNow.Models.Requests;
using Microsoft.EntityFrameworkCore;
using Mapster;
using CinemaNow.Models.DTOs;
using Stripe;
using System.Drawing;
using System.IO;
using QRCoder;

namespace CinemaNow.Services
{
    public class ReservationService : BaseCRUDService<Models.Reservation, ReservationSearchObject, Database.Reservation, ReservationInsertRequest, ReservationUpdateRequest>, IReservationService
    {
        private readonly IUserService _userService;
        private readonly Ib200033Context _context;
        private readonly PaymentService _paymentService;
        private PaymentService paymentService;

        public ReservationService(Ib200033Context context, IMapper mapper, IUserService userService, PaymentService paymentService) : base(context, mapper)
        {
            _userService = userService;
            _context = context;
            _paymentService = paymentService;
        }

        public override IQueryable<Database.Reservation> AddFilter(ReservationSearchObject search, IQueryable<Database.Reservation> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (search.ScreeningId.HasValue)
            {
                filteredQuery = filteredQuery.Where(r => r.ScreeningId == search.ScreeningId.Value);
            }
            if (search.UserId.HasValue)
            {
                filteredQuery = filteredQuery.Where(r => r.UserId == search.UserId.Value);
            }

            if (search?.IsUserIncluded == true)
                filteredQuery = filteredQuery.Include(x => x.User);

            if (search?.IsScreeningIncluded == true)
                filteredQuery = filteredQuery.Include(x => x.Screening);

            if (search?.AreSeatsIncluded == true)
            {
                filteredQuery = filteredQuery
                    .Include(r => r.ReservationSeats)
                    .ThenInclude(rs => rs.Seat);
            }

            if (search?.IsPaymentIncluded == true)
                filteredQuery = filteredQuery.Include(x => x.Payment);

            return filteredQuery;
        }

        public override Models.PagedResult<Models.Reservation> GetPaged(ReservationSearchObject search)
        {
            var query = Context.Reservations.AsQueryable();

            query = AddFilter(search, query);

            int count = query.Count();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip(search.Page.Value * search.PageSize.Value).Take(search.PageSize.Value);
            }

            if (!string.IsNullOrWhiteSpace(search?.OrderBy))
            {
                query = query.OrderBy(search.OrderBy);
            }

            var entities = query.ToList();

            var models = entities.Select(entity =>
            {
                var model = entity.Adapt<Models.Reservation>();

                if (search?.IsUserIncluded == true)
                {
                    model.User = entity.User != null ? new Models.User
                    {
                        Id = entity.User.Id,
                        Name = entity.User.Name,
                        Surname = entity.User.Surname,
                        Email = entity.User.Email,
                        Username = entity.User.Username,
                    } : null;
                }
                else
                {
                    model.User = null;
                }

                if (search?.AreSeatsIncluded == true)
                {
                    model.Seats = entity.ReservationSeats.Select(rs => new Models.ReservationSeat
                    {
                        ReservationId = rs.ReservationId,
                        SeatId = rs.SeatId,
                        Seat = rs.Seat.Adapt<Models.Seat>()
                    }).ToList();
                }

                if (search?.IsScreeningIncluded == true)
                {
                    model.Screening = entity.Screening?.Adapt<Models.Screening>();
                }

                return model;
            }).ToList();

            return new Models.PagedResult<Models.Reservation>
            {
                ResultList = models,
                Count = count
            };
        }

        public override Models.Reservation GetByID(int id)
        {
            var entity = Context.Reservations
                .Include(r => r.User)
                .Include(r => r.Screening)
            .ThenInclude(s => s.Movie)
        .Include(r => r.Screening)
            .ThenInclude(s => s.Hall)
        .Include(r => r.Screening)
            .ThenInclude(s => s.ViewMode)
                .Include(r => r.ReservationSeats)
                    .ThenInclude(rs => rs.Seat)
                .Include(r => r.Payment)
                .FirstOrDefault(r => r.Id == id);

            if (entity != null)
            {
                var model = entity.Adapt<Models.Reservation>();

                model.Seats = entity.ReservationSeats.Select(rs => new Models.ReservationSeat
                {
                    ReservationId = rs.ReservationId,
                    SeatId = rs.SeatId,
                    Seat = rs.Seat.Adapt<Models.Seat>()
                }).ToList();

                model.User = entity.User != null ? new Models.User
                {
                    Id = entity.User.Id,
                    Name = entity.User.Name,
                    Surname = entity.User.Surname,
                    Email = entity.User.Email,
                    Username = entity.User.Username,
                } : null;

                model.Screening = entity.Screening != null ? new Models.Screening
                {
                    Id = entity.Screening.Id,
                    MovieId = entity.Screening.MovieId,
                    HallId = entity.Screening.HallId,
                    ViewModeId = entity.Screening.ViewModeId,
                    DateTime = entity.Screening.DateTime,
                    Price = entity.Screening.Price,
                    StateMachine = entity.Screening.StateMachine,

                    Movie = entity.Screening.Movie != null ? new Models.Movie
                    {
                        Id = entity.Screening.Movie.Id,
                        Title = entity.Screening.Movie.Title,
                        Duration = entity.Screening.Movie.Duration,
                        Synopsis = entity.Screening.Movie.Synopsis,
                    } : null,

                    Hall = entity.Screening.Hall != null ? new Models.Hall
                    {
                        Id = entity.Screening.Hall.Id,
                        Name = entity.Screening.Hall.Name,
                    } : null,

                    ViewMode = entity.Screening.ViewMode != null ? new Models.ViewMode
                    {
                        Id = entity.Screening.ViewMode.Id,
                        Name = entity.Screening.ViewMode.Name
                    } : null

                } : null;

                model.Payment = entity.Payment != null ? new Models.Payment
                {
                    Id = entity.Payment.Id,
                    Provider = entity.Payment.Provider,
                    TransactionId = entity.Payment.TransactionId,
                    Amount = entity.Payment.Amount,
                    DateTime = entity.Payment.DateTime,
                } : null;

                return model;
            }
            return null;
        }

        public string GenerateQRCode(int reservationId)
        {
            var reservation = GetByID(reservationId);
            if (reservation == null)
            {
                throw new Exception("Reservation not found");
            }

            var qrCodeContent = $"Reservation ID: {reservation.Id}\n" +
                                $"User: {reservation.User?.Username} ({reservation.User?.Name} {reservation.User?.Surname})\n" +
                                $"Movie: {reservation.Screening?.Movie?.Title}\n" +
                                $"Date: {reservation.Screening?.DateTime:dd-MM-yyyy HH:mm}\n" +
                                $"Hall: {reservation.Screening?.Hall?.Name}\n" +
                                $"View Mode: {reservation.Screening?.ViewMode?.Name}\n" +
                                $"Ticket Price: {reservation.Screening?.Price}\n" +
                                $"Reservation Date: {reservation.DateTime:dd-MM-yyyy HH:mm}\n" +
                                $"Seats: {string.Join(", ", reservation.Seats.Select(s => s.Seat.Name))}\n" +
                                $"Total Price: {reservation.TotalPrice}\n" +
                                $"Payment Type: {reservation.PaymentType}\n";

            QRCodeGenerator qrGenerator = new QRCodeGenerator();
            QRCodeData qrCodeData = qrGenerator.CreateQrCode(qrCodeContent, QRCodeGenerator.ECCLevel.Q);
            PngByteQRCode qrCode = new PngByteQRCode(qrCodeData);
            byte[] qrCodeImage = qrCode.GetGraphic(20);

            return Convert.ToBase64String(qrCodeImage);
        }

        public override Models.Reservation Insert(ReservationInsertRequest request)
        {
            using var transaction = Context.Database.BeginTransaction();

            try
            {
                int currentUserId = _userService.GetCurrentUserId();
                request.UserId = currentUserId;

                ValidateSeatsAvailability(request.ScreeningId, request.SeatIds);

                var screening = GetScreeningById(request.ScreeningId);

                if (screening.StateMachine != "active")
                {
                    throw new InvalidOperationException("Reservations can only be made for screenings that are active.");
                }

                var reservation = CreateReservationEntity(request, screening);

                if (!string.IsNullOrEmpty(request.StripePaymentIntentId))
                {
                    var payment = _paymentService.ProcessStripePayment(request.StripePaymentIntentId, reservation.TotalPrice.Value);
                    reservation.PaymentId = payment.Id;
                    reservation.PaymentType = "Stripe";
                    reservation.Payment = payment;
                }

                Context.Add(reservation);
                Context.SaveChanges();

                if (request.SeatIds != null && request.SeatIds.Any())
                {
                    ReserveSeatsForReservation(request.SeatIds, request.ScreeningId, reservation.Id);
                }

                var fullEntity = GetFullReservationById(reservation.Id);

                var model = MapToModel(fullEntity);

                string qrCodeBase64 = GenerateQRCode(reservation.Id);

                reservation.QrcodeBase64 = qrCodeBase64;

                transaction.Commit();

                return model;
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
        }

        private void ValidateSeatsAvailability(int screeningId, List<int> seatIds)
        {
            var unavailableSeats = Context.ScreeningSeats
                .Where(ss => ss.ScreeningId == screeningId && seatIds.Contains(ss.SeatId) && ss.IsReserved.Value)
                .Select(ss => ss.SeatId)
                .ToList();

            if (unavailableSeats.Any())
            {
                throw new InvalidOperationException($"The following seats are already reserved: {string.Join(", ", unavailableSeats)}");
            }
        }

        private Database.Screening GetScreeningById(int screeningId)
        {
            var screening = Context.Screenings.FirstOrDefault(s => s.Id == screeningId);
            if (screening == null)
            {
                throw new InvalidOperationException("Screening not found.");
            }
            return screening;
        }

        private Database.Reservation CreateReservationEntity(ReservationInsertRequest request, Database.Screening screening)
        {
            var numberOfTickets = request.SeatIds?.Count ?? 0;
            var totalPrice = screening.Price * numberOfTickets;

            var entity = Mapper.Map<Database.Reservation>(request);
            entity.NumberOfTickets = numberOfTickets;
            entity.TotalPrice = totalPrice;
            entity.DateTime = DateTime.Now;

            if (entity.PaymentId == null)
            {
                entity.PaymentType = "Cash";
            }

            return entity;
        }

        private void ReserveSeatsForReservation(List<int> seatIds, int screeningId, int reservationId)
        {
            foreach (var seatId in seatIds)
            {
                var reservationSeat = new Database.ReservationSeat
                {
                    ReservationId = reservationId,
                    SeatId = seatId,
                    ReservedAt = DateTime.Now
                };

                Context.ReservationSeats.Add(reservationSeat);

                var screeningSeat = Context.ScreeningSeats
                    .FirstOrDefault(ss => ss.ScreeningId == screeningId && ss.SeatId == seatId);

                if (screeningSeat != null)
                {
                    screeningSeat.IsReserved = true;
                }
            }

            Context.SaveChanges();
        }

        private Database.Reservation GetFullReservationById(int reservationId)
        {
            return Context.Reservations
                .Include(r => r.User)
                .Include(r => r.Screening)
                .Include(r => r.ReservationSeats)
                    .ThenInclude(rs => rs.Seat)
                .FirstOrDefault(r => r.Id == reservationId);
        }

        private Models.Reservation MapToModel(Database.Reservation fullEntity)
        {
            var model = fullEntity.Adapt<Models.Reservation>();

            model.Seats = fullEntity.ReservationSeats.Select(rs => new Models.ReservationSeat
            {
                ReservationId = rs.ReservationId,
                SeatId = rs.SeatId,
                Seat = rs.Seat.Adapt<Models.Seat>()
            }).ToList();

            if (fullEntity.Payment != null)
            {
                model.Payment = new Models.Payment
                {
                    Id = fullEntity.Payment.Id,
                    Provider = fullEntity.Payment.Provider,
                    TransactionId = fullEntity.Payment.TransactionId,
                    Amount = fullEntity.Payment.Amount,
                    DateTime = fullEntity.Payment.DateTime
                };
            }

            return model;
        }

        public override Models.Reservation Update(int id, ReservationUpdateRequest request)
        {
            throw new NotImplementedException("Update operation is not allowed for reservations.");
        }

        public override void Delete(int id)
        {
            using var transaction = Context.Database.BeginTransaction();

            try
            {
                var reservation = Context.Reservations
                    .Include(r => r.ReservationSeats)
                    .Include(r => r.Screening)
                    .FirstOrDefault(r => r.Id == id);

                if (reservation == null)
                {
                    throw new Exception("Reservation not found");
                }

                var currentUserId = _userService.GetCurrentUserId();
                if (reservation.UserId != currentUserId)
                {
                    throw new UnauthorizedAccessException("You can only delete your own reservations.");
                }

                if (reservation.PaymentType == "Stripe")
                {
                    throw new InvalidOperationException("Reservations paid with Stripe cannot be deleted.");
                }

                if (reservation.Screening.DateTime < DateTime.Now)
                {
                    throw new InvalidOperationException("Past reservations cannot be deleted.");
                }

                foreach (var reservationSeat in reservation.ReservationSeats)
                {
                    var screeningSeat = Context.ScreeningSeats
                        .FirstOrDefault(ss => ss.ScreeningId == reservation.ScreeningId && ss.SeatId == reservationSeat.SeatId);

                    if (screeningSeat != null)
                    {
                        screeningSeat.IsReserved = false;
                    }
                }

                Context.ReservationSeats.RemoveRange(reservation.ReservationSeats);
                Context.Reservations.Remove(reservation);

                Context.SaveChanges();
                transaction.Commit();
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
        }

        public List<ReservationMovieDto> GetReservationsByUserId(int userId)
        {
            var reservations = _context.Reservations
                .Include(r => r.Screening)
                .ThenInclude(s => s.Movie)
                .Where(r => r.UserId == userId)
                .Select(r => new ReservationMovieDto
                {
                    ReservationId = r.Id,
                    ReservationDate = r.DateTime ?? DateTime.MinValue,
                    ReservationPaymentType = r.PaymentType,
                    ScreeningId = r.ScreeningId ?? 0,
                    ScreeningDate = r.Screening.DateTime ?? DateTime.MinValue,
                    SeatIds = r.ReservationSeats.Select(rs => rs.SeatId).ToList(),

                    MovieId = r.Screening.Movie.Id,
                    MovieTitle = r.Screening.Movie.Title,
                    MovieDuration = r.Screening.Movie.Duration,
                    MovieSynopsis = r.Screening.Movie.Synopsis,
                    MovieImageBase64 = r.Screening.Movie.Image != null
    ? Convert.ToBase64String(r.Screening.Movie.Image)
    : null
                })
                .ToList();

            return reservations;
        }

        public List<Models.Reservation> GetReservationsByScreeningId(int screeningId)
        {
            var reservations = _context.Reservations
                .Include(r => r.User)
                .Include(r => r.Screening)
                    .ThenInclude(s => s.Movie)
                .Include(r => r.ReservationSeats)
                    .ThenInclude(rs => rs.Seat)
                .Include(r => r.Payment)
                .Where(r => r.ScreeningId == screeningId)
                .ToList();

            var reservationModels = reservations.Select(r => new Models.Reservation
            {
                Id = r.Id,
                UserId = r.UserId,
                ScreeningId = r.ScreeningId,
                DateTime = r.DateTime,
                NumberOfTickets = r.NumberOfTickets,
                TotalPrice = r.TotalPrice,
                PaymentId = r.PaymentId,
                PaymentType = r.PaymentType,
                Seats = r.ReservationSeats.Select(rs => new Models.ReservationSeat
                {
                    ReservationId = rs.ReservationId,
                    SeatId = rs.SeatId,
                    Seat = rs.Seat != null ? new Models.Seat
                    {
                        Id = rs.Seat.Id,
                        Name = rs.Seat.Name
                    } : null
                }).ToList(),
                User = r.User != null ? new Models.User
                {
                    Id = r.User.Id,
                    Name = r.User.Name,
                    Surname = r.User.Surname,
                    Email = r.User.Email,
                    Username = r.User.Username
                } : null,
                Screening = r.Screening != null ? new Models.Screening
                {
                    Id = r.Screening.Id,
                    MovieId = r.Screening.MovieId,
                    HallId = r.Screening.HallId,
                    ViewModeId = r.Screening.ViewModeId,
                    DateTime = r.Screening.DateTime,
                    Price = r.Screening.Price,
                    Movie = r.Screening.Movie != null ? new Models.Movie
                    {
                        Id = r.Screening.Movie.Id,
                        Title = r.Screening.Movie.Title,
                        Duration = r.Screening.Movie.Duration,
                        Synopsis = r.Screening.Movie.Synopsis,
                        ImageBase64 = r.Screening.Movie.Image != null ? Convert.ToBase64String(r.Screening.Movie.Image) : null,
                        Actors = r.Screening.Movie.Actors.Select(a => new Models.Actor
                        {
                            Id = a.Id,
                            Name = a.Name
                        }).ToList(),
                        Genres = r.Screening.Movie.Genres.Select(g => new Models.Genre
                        {
                            Id = g.Id,
                            Name = g.Name
                        }).ToList()
                    } : null
                } : null,
                Payment = r.Payment != null ? new Models.Payment
                {
                    Id = r.Payment.Id,
                    Provider = r.Payment.Provider,
                    TransactionId = r.Payment.TransactionId,
                    Amount = r.Payment.Amount,
                    DateTime = r.Payment.DateTime
                } : null
            }).ToList();

            return reservationModels;
        }


    }
}