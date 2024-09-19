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
        private readonly IUserService _userService;

        public UserController(IUserService userService) : base(userService) {
            _userService = userService;
        }

        [HttpPost("login")]
        [AllowAnonymous]
        public ActionResult<Models.User> Login([FromBody] LoginRequest loginRequest)
        {
            var user = (_service as IUserService).Login(loginRequest.Username, loginRequest.Password);
            if (user == null)
            {
                return Unauthorized("Wrong username or password.");
            }
            return Ok(user);
        }

        [HttpPost]
        [AllowAnonymous]
        public override Models.User Insert(UserInsertRequest request)
        {
            return base.Insert(request);
        }

        [HttpPut("{id}")]
        [AllowAnonymous]
        public override Models.User Update(int id, UserUpdateRequest request)
        {
            return base.Update(id, request);
        }


        [HttpGet]
        [AllowAnonymous]
        public override PagedResult<User> GetList([FromQuery] UserSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [HttpGet("check-username")]
        [AllowAnonymous]

        public async Task<IActionResult> CheckUsername(string username)
        {
            var isTaken = await _userService.IsUsernameTaken(username);
            return Ok(isTaken);
        }

    }
}
