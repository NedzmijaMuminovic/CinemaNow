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
    public class ViewModeController : BaseCRUDController<ViewMode, ViewModeSearchObject, ViewModeUpsertRequest, ViewModeUpsertRequest>
    {
        public ViewModeController(IViewModeService service) : base(service)
        { 
        }

        public override ViewMode Insert(ViewModeUpsertRequest request)
        {
            return base.Insert(request);
        }

        public override PagedResult<ViewMode> GetList([FromQuery] ViewModeSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }
    }
}
