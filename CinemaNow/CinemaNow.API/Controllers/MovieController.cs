﻿using CinemaNow.Models;
using CinemaNow.Models.SearchObjects;
using CinemaNow.Services;
using Microsoft.AspNetCore.Mvc;

namespace CinemaNow.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class MovieController : BaseController<Movie, MovieSearchObject>
    {
        public MovieController(IMovieService service) : base(service)
        { 
        }
    }
}
