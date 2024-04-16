using CinemaNow.Models;
using CinemaNow.Models.SearchObjects;
using CinemaNow.Services;
using Microsoft.AspNetCore.Mvc;

namespace CinemaNow.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class GenreController : BaseController<Genre, GenreSearchObject>
    {
        public GenreController(IGenreService service) : base(service)
        { 
        }
    }
}
