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

namespace CinemaNow.Services
{
    public class GenreService : BaseService<Models.Genre, GenreSearchObject, Database.Genre>, IGenreService
    {

        public GenreService(Ib200033Context context, IMapper mapper) : base(context, mapper) {
        }

        public override IQueryable<Database.Genre> AddFilter(GenreSearchObject search, IQueryable<Database.Genre> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search?.NameGTE))
                filteredQuery = filteredQuery.Where(x => x.Name.StartsWith(search.NameGTE));

            return filteredQuery;
        }

    }
}
