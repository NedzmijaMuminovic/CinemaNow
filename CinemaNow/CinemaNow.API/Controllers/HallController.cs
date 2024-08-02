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
    public class HallController : BaseCRUDController<Hall, HallSearchObject, HallUpsertRequest, HallUpsertRequest>
    {
        public HallController(IHallService service) : base(service)
        { 
        }

        public override Hall Insert(HallUpsertRequest request)
        {
            return base.Insert(request);
        }

        public override PagedResult<Hall> GetList([FromQuery] HallSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }
    }
}
