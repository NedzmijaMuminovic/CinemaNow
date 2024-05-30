using CinemaNow.Models;
using CinemaNow.Models.Requests;
using CinemaNow.Models.SearchObjects;
using CinemaNow.Services;
using Microsoft.AspNetCore.Mvc;

namespace CinemaNow.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class SeatController : BaseCRUDController<Seat, SeatSearchObject, SeatUpsertRequest, SeatUpsertRequest>
    {
        public SeatController(ISeatService service) : base(service)
        {
        }
    }
}
