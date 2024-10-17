using CinemaNow.Models;
using CinemaNow.Models.MachineLearningModels;
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
        Task UpdateMovieImage(int movieId, byte[] image);
        IEnumerable<MovieData> LoadMovieData();
    }
}
