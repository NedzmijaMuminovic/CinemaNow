using CinemaNow.Models;
using CinemaNow.Models.Exceptions;
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
            if (User.IsInRole("User"))
            {
                return _service.Insert(request);
            }
            throw new ForbidException("Only users with the 'User' role can insert ratings.");
        }

        [HttpPut("{id}")]
        [AllowAnonymous]
        public override Rating Update(int id, RatingUpdateRequest request)
        {
            if (User.IsInRole("User"))
            {
                return _service.Update(id, request);
            }
            throw new ForbidException("Only users with the 'User' role can update ratings.");
        }

        [HttpDelete("{id}")]
        [AllowAnonymous]
        public override void Delete(int id)
        {
            if (User.IsInRole("User"))
            {
                _service.Delete(id);
            }
            else
            {
                throw new ForbidException("Only users with the 'User' role can delete ratings.");
            }
        }

        [HttpGet("average/{movieId}")]
        public IActionResult GetAverageRating(int movieId)
        {
            var averageRating = _ratingService.GetAverageRating(movieId);
            return Ok(new { AverageRating = averageRating });
        }

        [HttpGet("movie/{movieId}")]
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

        [HttpGet("hasRated/{userId}/{movieId}")]
        public IActionResult HasUserRatedMovie(int userId, int movieId)
        {
            try
            {
                var hasRated = _ratingService.HasUserRatedMovie(userId, movieId);
                return Ok(new { HasRated = hasRated });
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, $"Internal server error: {ex.Message}");
            }
        }

    }
}
