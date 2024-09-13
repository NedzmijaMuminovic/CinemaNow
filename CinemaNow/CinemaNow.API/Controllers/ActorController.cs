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

        public override Actor Insert(ActorUpsertRequest request)
        {
            return base.Insert(request);
        }

        public override PagedResult<Actor> GetList([FromQuery] ActorSearchObject searchObject)
        {
            return base.GetList(searchObject);
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

                var actorService = (IActorService)_service;
                await actorService.UpdateActorImage(id, imageBytes);
            }

            return Ok();
        }
    }
}
