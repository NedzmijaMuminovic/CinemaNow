using CinemaNow.Models;
using CinemaNow.Models.Requests;
using CinemaNow.Services.Database;
using MapsterMapper;
using Microsoft.Extensions.DependencyInjection;

namespace CinemaNow.Services.MovieStateMachine
{
    public class BaseMovieState //izmijeniti cijelu ovu logiku, ovo je u demonstrativne svrhe (vjezba)
    { 
        //initial, draft, active, hidden
        public Ib200033Context Context { get; set; }
        public IMapper Mapper { get; set; }
        public IServiceProvider ServiceProvider { get; set; }

        public BaseMovieState(Ib200033Context context, IMapper mapper, IServiceProvider serviceProvider)
        {
            Context = context;
            Mapper = mapper;
            ServiceProvider = serviceProvider;
        }

        public virtual Models.Movie Insert(MovieInsertRequest request)
        {
            throw new UserException("Method not allowed");
        }

        public virtual Models.Movie Update(int id, MovieUpdateRequest request)
        {
            throw new UserException("Method not allowed");
        }

        public virtual Models.Movie Activate(int id)
        {
            throw new UserException("Method not allowed");
        }

        public virtual Models.Movie Hide(int id)
        {
            throw new UserException("Method not allowed");
        }

        public virtual Models.Movie Edit(int id)
        {
            throw new UserException("Method not allowed");
        }

        public virtual List<string> AllowedActions(Database.Movie entity)
        {
            throw new UserException("Method not allowed");
        }

        public BaseMovieState CreateState(string stateName)
        {
            switch (stateName)
            {
                case "initial":
                    return ServiceProvider.GetService<InitialMovieState>();
                case "draft":
                    return ServiceProvider.GetService<DraftMovieState>();
                case "active":
                    return ServiceProvider.GetService<ActiveMovieState>();
                case "hidden":
                    return ServiceProvider.GetService<HiddenMovieState>();
                default: throw new Exception("State not recognised");
            }
        }

    }
}
