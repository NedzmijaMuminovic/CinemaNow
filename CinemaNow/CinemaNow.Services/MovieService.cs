using CinemaNow.Models;
using CinemaNow.Services.Database;
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
        public MovieService(Ib200033Context context) { 
            Context = context;
        }

        public virtual List<Models.Movie> GetList()
        {
            var list = Context.Movies.ToList();
            var result = new List<Models.Movie>();
            list.ForEach(item =>
            {
                result.Add(new Models.Movie()
                {
                    ID = item.Id,
                    Title = item.Title
                });
            });
            return result;
        }
    }
}
