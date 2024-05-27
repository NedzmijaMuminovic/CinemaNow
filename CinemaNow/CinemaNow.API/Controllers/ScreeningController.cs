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
    }
}
