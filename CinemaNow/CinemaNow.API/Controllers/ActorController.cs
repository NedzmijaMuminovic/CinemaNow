using CinemaNow.Models;
using CinemaNow.Models.Requests;
using CinemaNow.Models.SearchObjects;
using CinemaNow.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace CinemaNow.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ActorController : BaseCRUDController<Actor, ActorSearchObject, ActorUpsertRequest, ActorUpsertRequest>
    {
        public ActorController(IActorService service) : base(service)
        {
        }

        [Authorize(Roles = "Admin")]
        public override Actor Insert(ActorUpsertRequest request)
        {
            return base.Insert(request);
        }

        [AllowAnonymous]
        public override PagedResult<Actor> GetList([FromQuery] ActorSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }
    }
}
