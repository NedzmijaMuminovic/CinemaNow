using CinemaNow.Models;
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
        [Authorize(Roles = "User")]
        public override Rating Insert(RatingInsertRequest request)
        {
            return _service.Insert(request);
        }

        [HttpPut("{id}")]
        [AllowAnonymous]
        [Authorize(Roles = "User")]
        public override Rating Update(int id, RatingUpdateRequest request)
        {
            return _service.Update(id, request);
        }

        [HttpDelete("{id}")]
        [AllowAnonymous]
        [Authorize(Roles = "User")]
        public override void Delete(int id)
        {
            _service.Delete(id);
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
