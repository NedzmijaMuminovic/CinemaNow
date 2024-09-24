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

namespace CinemaNow.Services
{
    public class ReservationService : BaseCRUDService<Models.Reservation, ReservationSearchObject, Database.Reservation, ReservationInsertRequest, ReservationUpdateRequest>, IReservationService
    {
        public ReservationService(Ib200033Context context, IMapper mapper) : base(context, mapper)
        {
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
                    StateMachine = entity.Screening.StateMachine
                } : null;

                return model;
            }
            return null;
        }


    }

}
