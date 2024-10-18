using CinemaNow.Models;
using CinemaNow.Models.MachineLearningModels;
using Microsoft.ML;
using Microsoft.ML.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CinemaNow.Services.MachineLearning
{
    public class MovieRecommenderService : IMovieRecommenderService
    {
        private readonly MLContext _mlContext;
        private readonly IMovieService _movieService;
        private readonly List<string> _allGenres;
        private readonly List<string> _allActors;
        private readonly string _modelPath;

        public MovieRecommenderService(IMovieService movieService)
        {
            _mlContext = new MLContext();
            _movieService = movieService;

            _allGenres = GetAllGenres();
            _allActors = GetAllActors();

            string baseDirectory = AppDomain.CurrentDomain.BaseDirectory;

            string solutionDirectory = Path.GetFullPath(Path.Combine(baseDirectory, "..\\..\\..\\.."));

            string appDataPath = Path.Combine(solutionDirectory, "CinemaNow.API", "App_Data");

            Directory.CreateDirectory(appDataPath);

            _modelPath = Path.Combine(appDataPath, "movie-recommender-model.zip");
        }

        private List<string> GetAllGenres()
        {
            return _movieService.LoadMovieData()
                                .SelectMany(m => m.Genres)
                                .Distinct()
                                .ToList();
        }

        private List<string> GetAllActors()
        {
            return _movieService.LoadMovieData()
                                .SelectMany(m => m.Actors)
                                .Distinct()
                                .ToList();
        }

        public ITransformer BuildAndTrainModel(IEnumerable<MovieData> movieData)
        {
            var trainingData = _mlContext.Data.LoadFromEnumerable(movieData);

            var pipeline = _mlContext.Transforms.Text.FeaturizeText(
                                outputColumnName: "GenresFeaturized",
                                inputColumnName: nameof(MovieData.Genres))
                           .Append(_mlContext.Transforms.Text.FeaturizeText(
                                outputColumnName: "ActorsFeaturized",
                                inputColumnName: nameof(MovieData.Actors)))
                           .Append(_mlContext.Transforms.Text.FeaturizeText(
                                outputColumnName: "TitleFeaturized",
                                inputColumnName: nameof(MovieData.Title)))
                           .Append(_mlContext.Transforms.Concatenate(
                                outputColumnName: "Features",
                                "GenresFeaturized",
                                "ActorsFeaturized",
                                "TitleFeaturized"))
                           .Append(_mlContext.Regression.Trainers.Sdca());

            var model = pipeline.Fit(trainingData);
            return model;
        }

        public void TrainMovieRecommender()
        {
            var movieData = _movieService.LoadMovieData();
            var model = BuildAndTrainModel(movieData);

            _mlContext.Model.Save(model, null, _modelPath);
        }

        public List<MoviePrediction> RecommendMovies(int movieId)
        {
            var targetMovie = _movieService.GetByID(movieId);
            if (targetMovie == null)
                throw new Exception($"Movie with ID {movieId} not found");

            var movieData = ConvertMovieToMovieData(targetMovie);
            var targetVector = ConvertMovieToFeatureVector(movieData);

            var allMovies = _movieService.LoadMovieData().Where(m => m.Id != targetMovie.Id).ToList();

            var predictions = new List<MoviePrediction>();

            foreach (var movie in allMovies)
            {
                var movieVector = ConvertMovieToFeatureVector(movie);
                float similarityScore = CalculateCosineSimilarity(targetVector, movieVector);

                predictions.Add(new MoviePrediction
                {
                    Id = movie.Id,
                    Title = movie.Title,
                    ImageBase64 = movie.ImageBase64,
                    Score = similarityScore
                });
            }

            var recommendedMovies = predictions.OrderByDescending(p => p.Score).Take(5).ToList();
            return recommendedMovies;
        }

        private MovieData ConvertMovieToMovieData(Movie movie)
        {
            return new MovieData
            {
                Id = movie.Id,
                Title = movie.Title,
                Genres = movie.Genres.Select(g => g.Name).ToArray(),
                Actors = movie.Actors.Select(a => $"{a.Name} {a.Surname}").ToArray(),
                ImageBase64 = movie.ImageBase64
            };
        }

        private float[] ConvertMovieToFeatureVector(MovieData movie)
        {
            var genreVector = OneHotEncodeGenres(movie.Genres);
            var actorVector = OneHotEncodeActors(movie.Actors);

            return genreVector.Concat(actorVector).ToArray();
        }


        private float[] OneHotEncodeGenres(string[] genres)
        {
            var genreVector = new float[_allGenres.Count];

            foreach (var genre in genres)
            {
                var index = _allGenres.IndexOf(genre);
                if (index >= 0)
                {
                    genreVector[index] = 1;
                }
            }

            return genreVector;
        }

        private float[] OneHotEncodeActors(string[] actors)
        {
            var actorVector = new float[_allActors.Count];

            foreach (var actor in actors)
            {
                var index = _allActors.IndexOf(actor);
                if (index >= 0)
                {
                    actorVector[index] = 1;
                }
            }

            return actorVector;
        }

        private float CalculateCosineSimilarity(float[] vectorA, float[] vectorB)
        {
            if (vectorA.Length != vectorB.Length)
                throw new Exception("Vectors must be of the same length");

            float dotProduct = 0;
            float magnitudeA = 0;
            float magnitudeB = 0;

            for (int i = 0; i < vectorA.Length; i++)
            {
                dotProduct += vectorA[i] * vectorB[i];
                magnitudeA += vectorA[i] * vectorA[i];
                magnitudeB += vectorB[i] * vectorB[i];
            }

            return dotProduct / (float)(Math.Sqrt(magnitudeA) * Math.Sqrt(magnitudeB));
        }

    }
}
