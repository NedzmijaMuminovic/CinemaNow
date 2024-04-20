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

        [HttpPut("{id}/activate")]
        public Movie Activate(int id)
        {
            return (_service as IMovieService).Activate(id);
        }

        [HttpPut("{id}/edit")]
        public Movie Edit(int id)
        {
            return (_service as IMovieService).Edit(id);
        }

        [HttpPut("{id}/hide")]
        public Movie Hide(int id)
        {
            return (_service as IMovieService).Hide(id);
        }

        [HttpGet("{id}/allowedActions")]
        public List<string> AllowedActions(int id)
        {
            return (_service as IMovieService).AllowedActions(id);
        }

    }
}
