using CinemaNow.Models.MachineLearningModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CinemaNow.Services.MachineLearning
{
    public interface IMovieRecommenderService
    {
        List<MoviePrediction> RecommendMovies(int movieId);
        void TrainMovieRecommender();
    }
}
