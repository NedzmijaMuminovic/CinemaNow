using CinemaNow.Models.SearchObjects;
using CinemaNow.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Linq.Dynamic.Core;

namespace CinemaNow.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class BaseController<TModel, TSearch> : ControllerBase where TSearch : BaseSearchObject
    {
        protected IBaseService<TModel, TSearch> _service;

        public BaseController(IBaseService<TModel, TSearch> service)
        {
            _service = service;
        }

        [HttpGet]
        public virtual Models.PagedResult<TModel> GetList([FromQuery] TSearch searchObject)
        {
            return _service.GetPaged(searchObject);
        }

        [HttpGet("{id}")]
        public virtual TModel GetByID(int id)
        {
            return _service.GetByID(id);
        }
    }
}
