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
    public class SeatService : BaseCRUDService<Models.Seat, SeatSearchObject, Seat, SeatUpsertRequest, SeatUpsertRequest>, ISeatService
    {
        public SeatService(Ib200033Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Seat> AddFilter(SeatSearchObject search, IQueryable<Seat> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search?.FTS))
                filteredQuery = filteredQuery.Where(x => x.Name.Contains(search.FTS));

            return filteredQuery;
        }
    }
}
