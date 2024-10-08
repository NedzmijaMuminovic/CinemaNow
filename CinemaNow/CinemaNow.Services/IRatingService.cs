﻿using CinemaNow.Models;
using CinemaNow.Models.Requests;
using CinemaNow.Models.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CinemaNow.Services
{
    public interface IRatingService : IBaseCRUDService<Rating, RatingSearchObject, RatingInsertRequest, RatingUpdateRequest>
    {
        double? GetAverageRating(int movieId);
        public Task<IEnumerable<Models.Rating>> GetRatingsByMovieIdAsync(int movieId);
        public bool HasUserRatedMovie(int userId, int movieId);
    }
}
