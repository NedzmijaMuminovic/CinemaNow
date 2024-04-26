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
    public class GenreController : BaseCRUDController<Genre, GenreSearchObject, GenreUpsertRequest, GenreUpsertRequest>
    {
        public GenreController(IGenreService service) : base(service)
        { 
        }

        [Authorize(Roles = "Admin")]
        public override Genre Insert(GenreUpsertRequest request)
        {
            return base.Insert(request);
        }

        [AllowAnonymous]
        public override PagedResult<Genre> GetList([FromQuery] GenreSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }
    }
}
