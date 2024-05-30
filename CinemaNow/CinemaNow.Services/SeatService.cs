using CinemaNow.Models.Requests;
using CinemaNow.Models.SearchObjects;
using CinemaNow.Services.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CinemaNow.Services
{
    public class SeatService : BaseCRUDService<Models.Seat, SeatSearchObject, Database.Seat, SeatUpsertRequest, SeatUpsertRequest>, ISeatService
    {
        public SeatService(Ib200033Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Seat> AddFilter(SeatSearchObject search, IQueryable<Seat> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search?.FTS))
                filteredQuery = filteredQuery.Where(x => x.Name.Contains(search.FTS));

            if (search?.IsScreeningIncluded == true)
                filteredQuery = filteredQuery.Include(x => x.Screening.Movie);

            return filteredQuery;
        }

        public override Models.Seat GetByID(int id)
        {
            var entity = Context.Seats.Include(s => s.Screening.Movie).FirstOrDefault(s => s.Id == id);

            if (entity != null)
                return Mapper.Map<Models.Seat>(entity);
            else
                return null;
        }

        public override void BeforeInsert(SeatUpsertRequest request, Seat entity)
        {
            var screening = Context.Screenings.Include(s => s.Movie).FirstOrDefault(s => s.Id == request.ScreeningId);
            if (screening == null)
                throw new Exception("Screening not found");

            base.BeforeInsert(request, entity);
        }

        public override void BeforeUpdate(SeatUpsertRequest request, Seat entity)
        {
            base.BeforeUpdate(request, entity);

            var screening = Context.Screenings.Include(s => s.Movie).FirstOrDefault(s => s.Id == request.ScreeningId);
            if (screening == null)
                throw new Exception("Screening not found");
        }
    }
}
