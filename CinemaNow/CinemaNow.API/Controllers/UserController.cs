using CinemaNow.Models;
using CinemaNow.Models.Requests;
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
        public List<Models.User> GetList()
        {
            return _service.GetList();
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
