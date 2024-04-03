using CinemaNow.Models;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CinemaNow.Services
{
    public class DummyMovieService : IMovieService
    {
        public new List<Movie> List = new List<Movie>() 
        { 
            new Movie()
            {
                ID = 1,
                Title = "Barbie"
            }
        };
        public List<Movie> GetList()
        {
            return List;
        }
    }
}
