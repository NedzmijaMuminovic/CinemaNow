using CinemaNow.Models;
using CinemaNow.Models.SearchObjects;
using CinemaNow.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Linq.Dynamic.Core;
using CinemaNow.Models.Requests;
using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;
using CinemaNow.Models.MachineLearningModels;

namespace CinemaNow.Services
{
    public class MovieService : BaseCRUDService<Models.Movie, MovieSearchObject, Database.Movie, MovieInsertRequest, MovieUpdateRequest>, IMovieService
    {
        public MovieService(Ib200033Context context, IMapper mapper) : base(context, mapper) { 
        }

        public override IQueryable<Database.Movie> AddFilter(MovieSearchObject searchObject, IQueryable<Database.Movie> query)
        {
            var filteredQuery = base.AddFilter(searchObject, query);

            if (!string.IsNullOrWhiteSpace(searchObject?.FTS))
                filteredQuery = filteredQuery.Where(x => x.Title.Contains(searchObject.FTS));

            if (searchObject?.IsActorIncluded == true)
                filteredQuery = filteredQuery.Include(x => x.Actors).AsSplitQuery();

            if (searchObject?.IsGenreIncluded == true)
                filteredQuery = filteredQuery.Include(x => x.Genres).AsSplitQuery();

            return filteredQuery;
        }

        public override Models.PagedResult<Models.Movie> GetPaged(MovieSearchObject search)
        {
            var pagedData = base.GetPaged(search);

            foreach (var movie in pagedData.ResultList)
            {
                var dbMovie = Context.Set<Database.Movie>().Find(movie.Id);
                if (dbMovie != null)
                {
                    movie.ImageBase64 = dbMovie.Image != null ? Convert.ToBase64String(dbMovie.Image) : null;

                    foreach (var actor in movie.Actors)
                    {
                        var dbActor = dbMovie.Actors.FirstOrDefault(a => a.Id == actor.Id);
                        if (dbActor != null)
                        {
                            actor.ImageBase64 = dbActor.Image != null ? Convert.ToBase64String(dbActor.Image) : null;
                        }
                    }
                }
            }

            return pagedData;
        }

        public override Models.Movie GetByID(int id)
        {
            var entity = Context.Movies.Include(m => m.Actors).Include(m => m.Genres).AsSplitQuery().FirstOrDefault(m => m.Id == id);

            if (entity != null)
            {
                var model = Mapper.Map<Models.Movie>(entity);

                model.ImageBase64 = entity.Image != null ? Convert.ToBase64String(entity.Image) : null;

                if (entity.Actors != null)
                {
                    foreach (var actor in model.Actors)
                    {
                        var dbActor = entity.Actors.FirstOrDefault(a => a.Id == actor.Id);
                        if (dbActor != null)
                        {
                            actor.ImageBase64 = dbActor.Image != null ? Convert.ToBase64String(dbActor.Image) : null;
                        }
                    }
                }

                return model;
            }
            else
                return null;
        }

        public async Task UpdateMovieImage(int id, byte[] imageBytes)
        {
            var movie = Context.Set<Database.Movie>().Find(id);
            if (movie != null)
            {
                movie.Image = imageBytes;
                await Context.SaveChangesAsync();
            }
        }

        public override void BeforeInsert(MovieInsertRequest request, Database.Movie entity)
        {
            if (!string.IsNullOrEmpty(request.ImageBase64))
            {
                entity.Image = Convert.FromBase64String(request.ImageBase64);
            }

            if (request.ActorIds != null)
            {
                foreach (var actorId in request.ActorIds)
                {
                    var actor = Context.Actors.FirstOrDefault(a => a.Id == actorId);
                    if (actor == null)
                        throw new Exception($"Actor with ID {actorId} not found");

                    entity.Actors.Add(actor);
                }
            }

            if (request.GenreIds != null)
            {
                foreach (var genreId in request.GenreIds)
                {
                    var genre = Context.Genres.FirstOrDefault(g => g.Id == genreId);
                    if (genre == null)
                        throw new Exception($"Genre with ID {genreId} not found");

                    entity.Genres.Add(genre);
                }
            }

            base.BeforeInsert(request, entity);
        }

        public override void BeforeUpdate(MovieUpdateRequest request, Database.Movie entity)
        {
            if (!string.IsNullOrEmpty(request.ImageBase64))
            {
                entity.Image = Convert.FromBase64String(request.ImageBase64);
            }
            else
            {
                entity.Image = null;
            }

            Context.Entry(entity).Collection(e => e.Actors).Load();
            Context.Entry(entity).Collection(e => e.Genres).Load();

            entity.Actors.Clear();
            entity.Genres.Clear();
            Context.SaveChanges();

            foreach (var actorId in request.ActorIds)
            {
                var actor = Context.Actors.FirstOrDefault(a => a.Id == actorId);
                if (actor == null)
                    throw new Exception($"Actor with ID {actorId} not found");

                if (!entity.Actors.Any(a => a.Id == actorId))
                {
                    entity.Actors.Add(actor);
                }
            }

            foreach (var genreId in request.GenreIds)
            {
                var genre = Context.Genres.FirstOrDefault(g => g.Id == genreId);
                if (genre == null)
                    throw new Exception($"Genre with ID {genreId} not found");

                if (!entity.Genres.Any(g => g.Id == genreId))
                {
                    entity.Genres.Add(genre);
                }
            }

            base.BeforeUpdate(request, entity);

        }

        public IEnumerable<MovieData> LoadMovieData()
        {
            var movies = Context.Movies.Include(m => m.Genres).Include(m => m.Actors).ToList();

            var movieData = new List<MovieData>();

            foreach (var movie in movies)
            {
                movieData.Add(new MovieData
                {
                    Id = movie.Id,
                    Title = movie.Title,
                    Genres = movie.Genres.Select(g => g.Name).ToArray(),
                    Actors = movie.Actors.Select(a => $"{a.Name} {a.Surname}").ToArray(),
                    ImageBase64 = movie.Image != null ? Convert.ToBase64String(movie.Image) : null
                });
            }

            return movieData;
        }


    }
}
