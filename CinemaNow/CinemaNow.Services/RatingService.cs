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
using Microsoft.AspNetCore.Http;

namespace CinemaNow.Services
{
    public class RatingService : BaseCRUDService<Models.Rating, RatingSearchObject, Database.Rating, RatingInsertRequest, RatingUpdateRequest>, IRatingService
    {
        private readonly IUserService _userService;

        public RatingService(Ib200033Context context, IMapper mapper, IUserService userService) : base(context, mapper)
        {
            _userService = userService;
        }

        public override Models.PagedResult<Models.Rating> GetPaged(RatingSearchObject search)
        {
            var query = Context.Set<Database.Rating>().AsQueryable();
            query = AddFilter(search, query);

            int count = query.Count();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
                query = query.Skip(search.Page.Value * search.PageSize.Value).Take(search.PageSize.Value);

            if (!string.IsNullOrWhiteSpace(search?.OrderBy))
                query = query.OrderBy(search.OrderBy);

            var list = query.ToList();
            var result = Mapper.Map<List<Models.Rating>>(list);

            foreach (var rating in result)
            {
                if (search?.IsUserIncluded == true)
                {
                    var dbRating = list.FirstOrDefault(r => r.Id == rating.Id);
                    if (dbRating?.User != null)
                    {
                        rating.User.ImageBase64 = dbRating.User.Image != null ?
                            Convert.ToBase64String(dbRating.User.Image) : null;
                    }
                }
                else
                {
                    rating.User = null;
                }

                if (search?.IsMovieIncluded != true)
                {
                    rating.Movie = null;
                }
            }

            return new Models.PagedResult<Models.Rating>
            {
                ResultList = result,
                Count = count
            };
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
            var ratings = await Context.Ratings
                .Where(r => r.MovieId == movieId)
                .Include(r => r.User)
                .Include(r => r.Movie)
                .ToListAsync();

            return ratings.Select(r =>
            {
                var rating = Mapper.Map<Models.Rating>(r);
                if (r.User != null && r.User.Image != null)
                {
                    rating.User.ImageBase64 = Convert.ToBase64String(r.User.Image);
                }
                return rating;
            });
        }

        public override void Delete(int id)
        {
            var rating = Context.Ratings.Find(id);
            if (rating == null)
            {
                throw new Exception("Rating not found");
            }

            var currentUserId = _userService.GetCurrentUserId();
            if (rating.UserId != currentUserId)
            {
                throw new UnauthorizedAccessException("You can only delete your own ratings.");
            }

            Context.Ratings.Remove(rating);
            Context.SaveChanges();
        }

        public override Models.Rating Update(int id, RatingUpdateRequest request)
        {
            if (request.Value < 1 || request.Value > 5)
            {
                throw new ArgumentOutOfRangeException(nameof(request.Value), "Rating value must be between 1 and 5.");
            }

            var rating = Context.Ratings.Include(r => r.Movie).FirstOrDefault(r => r.Id == id);
            if (rating == null)
            {
                throw new Exception("Rating not found");
            }

            var currentUserId = _userService.GetCurrentUserId();
            if (rating.UserId != currentUserId)
            {
                throw new UnauthorizedAccessException("You can only update your own ratings.");
            }

            var updatedRating = base.Update(id, request);
            updatedRating.Movie = Mapper.Map<Models.Movie>(rating.Movie);

            return updatedRating;
        }

        public bool HasUserRatedMovie(int userId, int movieId)
        {
            return Context.Ratings.Any(r => r.UserId == userId && r.MovieId == movieId);
        }

        public override Models.Rating Insert(RatingInsertRequest request)
        {
            if (request.Value < 1 || request.Value > 5)
            {
                throw new ArgumentOutOfRangeException(nameof(request.Value), "Rating value must be between 1 and 5.");
            }

            var currentUserId = _userService.GetCurrentUserId();
            if (HasUserRatedMovie(currentUserId, request.MovieId))
            {
                throw new InvalidOperationException("You have already rated this movie.");
            }

            request.UserId = currentUserId;
            var rating = base.Insert(request);

            var user = Context.Users.Find(currentUserId);
            var movie = Context.Movies.Find(request.MovieId);

            if (user?.Image != null)
            {
                rating.User.ImageBase64 = Convert.ToBase64String(user.Image);
            }

            rating.Movie = Mapper.Map<Models.Movie>(movie);

            return rating;
        }

    }
}