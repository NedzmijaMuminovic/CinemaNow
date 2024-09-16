﻿using CinemaNow.Models;
using CinemaNow.Models.Requests;
using CinemaNow.Models.SearchObjects;
using CinemaNow.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CinemaNow.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class RatingController : BaseCRUDController<Rating, RatingSearchObject, RatingInsertRequest, RatingUpdateRequest>
    {
        private readonly IRatingService _ratingService;

        public RatingController(IRatingService service) : base(service)
        {
            _ratingService = service;
        }

        [HttpPost]
        [AllowAnonymous]
        public override Rating Insert(RatingInsertRequest request)
        {
            return _service.Insert(request);
        }

        [HttpPut("{id}")]
        [AllowAnonymous]
        public override Rating Update(int id, RatingUpdateRequest request)
        {
            return _service.Update(id, request);
        }

        [HttpDelete("{id}")]
        [AllowAnonymous]
        public override void Delete(int id)
        {
            _service.Delete(id);
        }

        [HttpGet("average/{movieId}")]
        [AllowAnonymous]
        public IActionResult GetAverageRating(int movieId)
        {
            var averageRating = _ratingService.GetAverageRating(movieId);
            return Ok(new { AverageRating = averageRating });
        }

        [HttpGet("movie/{movieId}")]
        [AllowAnonymous]
        public async Task<IActionResult> GetRatingsByMovieId(int movieId)
        {
            try
            {
                var ratings = await _ratingService.GetRatingsByMovieIdAsync(movieId);
                return Ok(ratings);
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, $"Internal server error: {ex.Message}");
            }
        }
    }
}
