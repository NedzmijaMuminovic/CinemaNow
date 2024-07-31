using CinemaNow.Models;
using CinemaNow.Models.Requests;
using CinemaNow.Models.SearchObjects;
using CinemaNow.Services;
using Microsoft.AspNetCore.Mvc;

namespace CinemaNow.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class MovieController : BaseCRUDController<Movie, MovieSearchObject, MovieInsertRequest, MovieUpdateRequest>
    {
        public MovieController(IMovieService service) : base(service)
        { 
        }

        [HttpPost("upload-image/{id}")]
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

    }
}
