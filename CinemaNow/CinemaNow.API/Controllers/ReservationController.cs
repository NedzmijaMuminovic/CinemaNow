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
    public class ReservationController : BaseCRUDController<Reservation, ReservationSearchObject, ReservationInsertRequest, ReservationUpdateRequest>
    {
        public ReservationController(IReservationService service) : base(service)
        {
        }

        [HttpGet]
        public override PagedResult<Reservation> GetList([FromQuery] ReservationSearchObject searchObject)
        {
            return _service.GetPaged(searchObject);
        }

        [HttpGet("{id}")]
        public override Reservation GetByID(int id)
        {
            return _service.GetByID(id);
        }
    }

}
