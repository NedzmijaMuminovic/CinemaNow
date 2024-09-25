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

        [HttpPost]
        [AllowAnonymous]
        [Authorize(Roles = "User")]
        public override Reservation Insert(ReservationInsertRequest request)
        {
            return _service.Insert(request);
        }

        [HttpPut("{id}")]
        [AllowAnonymous]
        [Authorize(Roles = "User")]
        public override Reservation Update(int id, ReservationUpdateRequest request)
        {
            return _service.Update(id, request);
        }

        [HttpDelete("{id}")]
        [AllowAnonymous]
        [Authorize(Roles = "User")]
        public override void Delete(int id)
        {
            _service.Delete(id);
        }
    }

}
