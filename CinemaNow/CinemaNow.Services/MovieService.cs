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
    public class MovieService : BaseService<Models.Movie, MovieSearchObject, Database.Movie>, IMovieService
    {
        public MovieService(Ib200033Context context, IMapper mapper) : base(context, mapper) { 
        }

        public override IQueryable<Database.Movie> AddFilter(MovieSearchObject search, IQueryable<Database.Movie> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search?.FTS))
                filteredQuery = filteredQuery.Where(x => x.Title.Contains(search.FTS));

            return filteredQuery;
        }

    }
}
