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
using CinemaNow.Services.MovieStateMachine;
using Azure.Core;
using Microsoft.Extensions.Logging;

namespace CinemaNow.Services
{
    public class MovieService : BaseCRUDService<Models.Movie, MovieSearchObject, Database.Movie, MovieInsertRequest, MovieUpdateRequest>, IMovieService
    {
        public BaseMovieState BaseMovieState { get; set; }
        ILogger<MovieService> _logger;

        public MovieService(Ib200033Context context, IMapper mapper, BaseMovieState baseMovieState, ILogger<MovieService> logger) : base(context, mapper) { 
            BaseMovieState = baseMovieState;
            _logger = logger;
        }

        public override IQueryable<Database.Movie> AddFilter(MovieSearchObject search, IQueryable<Database.Movie> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search?.FTS))
                filteredQuery = filteredQuery.Where(x => x.Title.Contains(search.FTS));

            return filteredQuery;
        }

        public override Models.Movie Insert(MovieInsertRequest request)
        {
            var state = BaseMovieState.CreateState("initial");
            return state.Insert(request);
        }

        public override Models.Movie Update(int id, MovieUpdateRequest request)
        {
            var entity = GetByID(id);
            var state = BaseMovieState.CreateState(entity.StateMachine);
            return state.Update(id, request);
        }

        public Models.Movie Activate(int id)
        {
            var entity = GetByID(id);
            var state = BaseMovieState.CreateState(entity.StateMachine);
            return state.Activate(id);
        }

        public Models.Movie Edit(int id)
        {
            var entity = GetByID(id);
            var state = BaseMovieState.CreateState(entity.StateMachine);
            return state.Edit(id);
        }

        public Models.Movie Hide(int id)
        {
            var entity = GetByID(id);
            var state = BaseMovieState.CreateState(entity.StateMachine);
            return state.Hide(id);
        }

        public List<string> AllowedActions(int id)
        {
            _logger.LogInformation($"Allowed actions called for: {id}");
            if (id <= 0)
            {
                var state = BaseMovieState.CreateState("initial");
                return state.AllowedActions(null);
            }
            else
            {
                var entity = Context.Movies.Find(id);
                var state = BaseMovieState.CreateState(entity.StateMachine);
                return state.AllowedActions(entity);
            }
        }

    }
}
