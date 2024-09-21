﻿using CinemaNow.Models;
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
            if (request.Value.HasValue && (request.Value.Value < 1 || request.Value.Value > 5))
            {
                throw new ArgumentOutOfRangeException(nameof(request.Value), "Rating value must be between 1 and 5.");
            }

            var rating = Context.Ratings.Find(id);
            if (rating == null)
            {
                throw new Exception("Rating not found");
            }

            var currentUserId = _userService.GetCurrentUserId();
            if (rating.UserId != currentUserId)
            {
                throw new UnauthorizedAccessException("You can only update your own ratings.");
            }

            return base.Update(id, request);
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
            return base.Insert(request);
        }

    }
}