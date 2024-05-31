using CinemaNow.Models;
using CinemaNow.Models.Requests;
using CinemaNow.Models.SearchObjects;
using CinemaNow.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace CinemaNow.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ScreeningController : BaseCRUDController<Screening, ScreeningSearchObject, ScreeningInsertRequest, ScreeningUpdateRequest>
    {
        public ScreeningController(IScreeningService service) : base(service)
        {
        }

        [HttpPut("{id}/activate")]
        public Screening Activate(int id)
        {
            return (_service as IScreeningService).Activate(id);
        }

        [HttpPut("{id}/edit")]
        public Screening Edit(int id)
        {
            return (_service as IScreeningService).Edit(id);
        }

        [HttpPut("{id}/hide")]
        public Screening Hide(int id)
        {
            return (_service as IScreeningService).Hide(id);
        }

        [HttpGet("{id}/allowedActions")]
        public List<string> AllowedActions(int id)
        {
            return (_service as IScreeningService).AllowedActions(id);
        }
    }
}
