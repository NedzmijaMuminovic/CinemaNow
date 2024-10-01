using CinemaNow.Models;
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

namespace CinemaNow.Services
{
    public class ReservationService : BaseCRUDService<Models.Reservation, ReservationSearchObject, Database.Reservation, ReservationInsertRequest, ReservationUpdateRequest>, IReservationService
    {
        private readonly IUserService _userService;
        private readonly Ib200033Context _context;

        public ReservationService(Ib200033Context context, IMapper mapper, IUserService userService) : base(context, mapper)
        {
            _userService = userService;
            _context = context;
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

            var entities = query.ToList();

            var models = entities.Select(entity =>
            {
                var model = entity.Adapt<Models.Reservation>();

                if (search?.AreSeatsIncluded == true)
                {
                    model.Seats = entity.ReservationSeats.Select(rs => new Models.ReservationSeat
                    {
                        ReservationId = rs.ReservationId,
                        SeatId = rs.SeatId,
                        Seat = rs.Seat.Adapt<Models.Seat>()
                    }).ToList();
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

                return model;
            }
            return null;
        }

        public override Models.Reservation Insert(ReservationInsertRequest request)
        {
            using var transaction = Context.Database.BeginTransaction();

            try
            {
                int currentUserId = _userService.GetCurrentUserId();

                request.UserId = currentUserId;

                var unavailableSeats = Context.ScreeningSeats
                    .Where(ss => ss.ScreeningId == request.ScreeningId && request.SeatIds.Contains(ss.SeatId) && ss.IsReserved == true)
                    .Select(ss => ss.SeatId)
                    .ToList();

                if (unavailableSeats.Any())
                {
                    throw new InvalidOperationException($"The following seats are already reserved: {string.Join(", ", unavailableSeats)}");
                }

                var entity = Mapper.Map<Database.Reservation>(request);

                Context.Add(entity);
                Context.SaveChanges();

                if (request.SeatIds != null && request.SeatIds.Any())
                {
                    foreach (var seatId in request.SeatIds)
                    {
                        var reservationSeat = new Database.ReservationSeat
                        {
                            ReservationId = entity.Id,
                            SeatId = seatId,
                            ReservedAt = DateTime.Now
                        };

                        Context.ReservationSeats.Add(reservationSeat);

                        var screeningSeat = Context.ScreeningSeats
                            .FirstOrDefault(ss => ss.ScreeningId == request.ScreeningId && ss.SeatId == seatId);

                        if (screeningSeat != null)
                        {
                            screeningSeat.IsReserved = true;
                        }
                    }

                    Context.SaveChanges();
                }

                var fullEntity = Context.Reservations
                    .Include(r => r.User)
                    .Include(r => r.Screening)
                    .Include(r => r.ReservationSeats)
                        .ThenInclude(rs => rs.Seat)
                    .FirstOrDefault(r => r.Id == entity.Id);

                var model = fullEntity.Adapt<Models.Reservation>();

                model.Seats = fullEntity.ReservationSeats.Select(rs => new Models.ReservationSeat
                {
                    ReservationId = rs.ReservationId,
                    SeatId = rs.SeatId,
                    Seat = rs.Seat.Adapt<Models.Seat>()
                }).ToList();

                transaction.Commit();

                return model;
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
        }

        public override Models.Reservation Update(int id, ReservationUpdateRequest request)
        {
            using var transaction = Context.Database.BeginTransaction();

            try
            {
                var entity = Context.Reservations
                    .Include(r => r.ReservationSeats)
                    .FirstOrDefault(r => r.Id == id);

                if (entity == null)
                    throw new Exception("Reservation not found");

                var currentUserId = _userService.GetCurrentUserId();
                if (entity.UserId != currentUserId)
                {
                    throw new UnauthorizedAccessException("You can only update your own reservations.");
                }

                var currentScreeningId = entity.ScreeningId;

                Mapper.Map(request, entity);

                bool screeningChanged = currentScreeningId != entity.ScreeningId;

                if (screeningChanged)
                {
                    var screeningSeatsToRelease = Context.ScreeningSeats
                        .Where(ss => ss.ScreeningId == currentScreeningId &&
                                     entity.ReservationSeats.Select(rs => rs.SeatId).Contains(ss.SeatId));

                    foreach (var seat in screeningSeatsToRelease)
                    {
                        seat.IsReserved = false;
                    }
                }

                if (request.SeatIds != null && request.SeatIds.Any())
                {
                    var unavailableSeats = Context.ScreeningSeats
                        .Where(ss => ss.ScreeningId == entity.ScreeningId &&
                                     request.SeatIds.Contains(ss.SeatId) &&
                                     ss.IsReserved == true &&
                                     !entity.ReservationSeats.Select(rs => rs.SeatId).Contains(ss.SeatId))
                        .Select(ss => ss.SeatId)
                        .ToList();

                    if (unavailableSeats.Any())
                    {
                        throw new InvalidOperationException($"The following seats are already reserved: {string.Join(", ", unavailableSeats)}");
                    }

                    var seatsToRemove = entity.ReservationSeats
                        .Where(rs => !request.SeatIds.Contains(rs.SeatId))
                        .ToList();

                    foreach (var seatToRemove in seatsToRemove)
                    {
                        entity.ReservationSeats.Remove(seatToRemove);

                        var screeningSeat = Context.ScreeningSeats
                            .FirstOrDefault(ss => ss.ScreeningId == entity.ScreeningId && ss.SeatId == seatToRemove.SeatId);

                        if (screeningSeat != null)
                        {
                            screeningSeat.IsReserved = false;
                        }
                    }

                    var existingSeats = entity.ReservationSeats.Select(rs => rs.SeatId).ToList();
                    var seatsToAdd = request.SeatIds.Except(existingSeats);

                    foreach (var seatId in seatsToAdd)
                    {
                        var reservationSeat = new Database.ReservationSeat
                        {
                            ReservationId = entity.Id,
                            SeatId = seatId,
                            ReservedAt = DateTime.UtcNow
                        };
                        entity.ReservationSeats.Add(reservationSeat);

                        var screeningSeat = Context.ScreeningSeats
                            .FirstOrDefault(ss => ss.ScreeningId == entity.ScreeningId && ss.SeatId == seatId);

                        if (screeningSeat != null)
                        {
                            screeningSeat.IsReserved = true;
                        }
                    }
                }
                else
                {
                    entity.ReservationSeats.Clear();

                    var screeningSeatsToRelease = Context.ScreeningSeats
                        .Where(ss => ss.ScreeningId == entity.ScreeningId &&
                                     entity.ReservationSeats.Select(rs => rs.SeatId).Contains(ss.SeatId));

                    foreach (var seat in screeningSeatsToRelease)
                    {
                        seat.IsReserved = false;
                    }
                }

                Context.SaveChanges();

                var updatedEntity = Context.Reservations
                    .Include(r => r.User)
                    .Include(r => r.Screening)
                    .Include(r => r.ReservationSeats)
                        .ThenInclude(rs => rs.Seat)
                    .FirstOrDefault(r => r.Id == entity.Id);

                var model = updatedEntity.Adapt<Models.Reservation>();

                model.Seats = updatedEntity.ReservationSeats.Select(rs => new Models.ReservationSeat
                {
                    ReservationId = rs.ReservationId,
                    SeatId = rs.SeatId,
                    Seat = rs.Seat.Adapt<Models.Seat>()
                }).ToList();

                transaction.Commit();

                return model;
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
        }

        public override void Delete(int id)
        {
            using var transaction = Context.Database.BeginTransaction();

            try
            {
                var reservation = Context.Reservations
                    .Include(r => r.ReservationSeats)
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
    }

}