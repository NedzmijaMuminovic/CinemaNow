using CinemaNow.Models;
using CinemaNow.Models.SearchObjects;
using CinemaNow.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CinemaNow.Services
{
    public class MovieService : IMovieService
    {
        public Ib200033Context Context { get; set; }
        public IMapper Mapper { get; set; }

        public MovieService(Ib200033Context context, IMapper mapper) { 
            Context = context;
            Mapper = mapper;
        }

        public virtual List<Models.Movie> GetList(MovieSearchObject searchObject)
        {
            List<Models.Movie> result = new List<Models.Movie>();

            var query = Context.Movies.AsQueryable();

            if (!string.IsNullOrWhiteSpace(searchObject?.FTS))
                query = query.Where(x => x.Title.Contains(searchObject.FTS));

            var list = query.ToList();

            result = Mapper.Map(list, result);

            return result;
        }
    }
}
