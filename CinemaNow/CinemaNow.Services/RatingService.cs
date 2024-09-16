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
using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;

namespace CinemaNow.Services
{
    public class RatingService : BaseCRUDService<Models.Rating, RatingSearchObject, Database.Rating, RatingInsertRequest, RatingUpdateRequest>, IRatingService
    {
        public RatingService(Ib200033Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Database.Rating> AddFilter(RatingSearchObject search, IQueryable<Database.Rating> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (search.Value.HasValue)
            {
                filteredQuery = filteredQuery.Where(r => r.Value == search.Value.Value);
            }

            if (search?.IsUserIncluded == true)
                filteredQuery = filteredQuery.Include(x => x.User);

            if (search?.IsMovieIncluded == true)
                filteredQuery = filteredQuery.Include(x => x.Movie);

            return filteredQuery;
        }

        public override Models.Rating GetByID(int id)
        {
            var entity = Context.Ratings.Include(r => r.User).Include(r => r.Movie).FirstOrDefault(r => r.Id == id);

            if (entity != null)
            {
                var model = Mapper.Map<Models.Rating>(entity);

                return model;
            }
            return null;
        }

        public double? GetAverageRating(int movieId)
        {
            var ratings = Context.Ratings
                .Where(r => r.MovieId == movieId && r.Value.HasValue)
                .Select(r => r.Value.Value);
            if (!ratings.Any())
            {
                return null;
            }
            return ratings.Average();
        }

        public async Task<IEnumerable<Models.Rating>> GetRatingsByMovieIdAsync(int movieId)
        {
            return await Context.Ratings
                .Where(r => r.MovieId == movieId)
                .Include(r => r.User)
                .Include(r => r.Movie)
                .Select(r => Mapper.Map<Models.Rating>(r))
                .ToListAsync();
        }

    }
}