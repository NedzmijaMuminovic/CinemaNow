using CinemaNow.Models;
using CinemaNow.Models.Requests;
using CinemaNow.Models.SearchObjects;
using CinemaNow.Services;
using CinemaNow.Services.MachineLearning;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CinemaNow.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class MovieController : BaseCRUDController<Movie, MovieSearchObject, MovieInsertRequest, MovieUpdateRequest>
    {
        private readonly IMovieRecommenderService _movieRecommenderService;

        public MovieController(IMovieService service, IMovieRecommenderService movieRecommenderService) : base(service)
        {
            _movieRecommenderService = movieRecommenderService;
        }

        [HttpPost("upload-image/{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> UploadImage(int id, IFormFile file)
        {
            if (file == null || file.Length == 0)
                return BadRequest("No file uploaded.");

            using (var memoryStream = new MemoryStream())
            {
                await file.CopyToAsync(memoryStream);
                var imageBytes = memoryStream.ToArray();

                var movieService = (IMovieService)_service;
                await movieService.UpdateMovieImage(id, imageBytes);
            }

            return Ok();
        }

        [HttpGet("{id}/recommendations")]
        [Authorize]
        public IActionResult GetRecommendations(int id)
        {
            var recommendations = _movieRecommenderService.RecommendMovies(id);

            if (recommendations == null || recommendations.Count == 0)
                return NotFound("No similar movies found");

            return Ok(recommendations);
        }

    }
}
