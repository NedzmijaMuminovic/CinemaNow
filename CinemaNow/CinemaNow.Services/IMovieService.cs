using CinemaNow.Models;
using CinemaNow.Models.Requests;
using CinemaNow.Models.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CinemaNow.Services
{
    public interface IMovieService : IBaseCRUDService<Movie, MovieSearchObject, MovieInsertRequest, MovieUpdateRequest>
    {
        public Movie Activate(int id);
        public Movie Edit(int id);
        public Movie Hide(int id);
        public List<string> AllowedActions(int id);
    }
}
