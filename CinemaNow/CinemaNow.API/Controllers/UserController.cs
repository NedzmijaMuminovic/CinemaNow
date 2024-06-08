using CinemaNow.Models;
using CinemaNow.Models.Requests;
using CinemaNow.Models.SearchObjects;
using CinemaNow.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore.Storage;

namespace CinemaNow.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UserController : BaseCRUDController<Models.User, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        public UserController(IUserService service) : base(service) { }

        [HttpPost("login")]
        [AllowAnonymous]
        public Models.User Login(string username, string password)
        {
            return (_service as IUserService).Login(username, password);
        }

        [HttpPost]
        [AllowAnonymous]
        public override Models.User Insert(UserInsertRequest request)
        {
            return base.Insert(request);
        }
    }
}
