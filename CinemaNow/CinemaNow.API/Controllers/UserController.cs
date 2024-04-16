using CinemaNow.Models;
using CinemaNow.Models.Requests;
using CinemaNow.Models.SearchObjects;
using CinemaNow.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore.Storage;

namespace CinemaNow.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UserController : ControllerBase
    {
        protected IUserService _service;

        public UserController(IUserService service) 
        { 
            _service = service;
        }

        [HttpGet]
        public PagedResult<User> GetList([FromQuery] UserSearchObject searchObject)
        {
            return _service.GetList(searchObject);
        }

        [HttpPost]
        public User Insert(UserInsertRequest request)
        {
            return _service.Insert(request);
        }

        [HttpPut("{id}")]
        public User Update(int id, UserUpdateRequest request)
        {
            return _service.Update(id, request);
        }
    }
}
