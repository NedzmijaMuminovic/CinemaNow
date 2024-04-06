using CinemaNow.Models;
using CinemaNow.Models.SearchObjects;
using CinemaNow.Services;
using Microsoft.AspNetCore.Mvc;

namespace CinemaNow.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class MovieController : ControllerBase
    {
        protected IMovieService _service;

        public MovieController(IMovieService service) 
        { 
            _service = service;
        }

        [HttpGet]
        public List<Movie> GetList([FromQuery] MovieSearchObject searchObject)
        {
            return _service.GetList(searchObject);
        }
    }
}
