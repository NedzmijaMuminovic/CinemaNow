using Azure.Core;
using CinemaNow.Models.Messages;
using CinemaNow.Models.Requests;
using CinemaNow.Services.Database;
using EasyNetQ;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CinemaNow.Services.MovieStateMachine
{
    public class DraftMovieState : BaseMovieState
    {
        public DraftMovieState(Ib200033Context context, IMapper mapper, IServiceProvider serviceProvider) : base(context, mapper, serviceProvider)
        {
        }

        public override Models.Movie Update(int id, MovieUpdateRequest request)
        {
            var set = Context.Set<Movie>();
            var entity = set.Find(id);
            Mapper.Map(request, entity);
            Context.SaveChanges();
            return Mapper.Map<Models.Movie>(entity);
        }

        public override Models.Movie Activate(int id)
        {
            var set = Context.Set<Movie>();
            var entity = set.Find(id);
            entity.StateMachine = "active";
            Context.SaveChanges();

            var bus = RabbitHutch.CreateBus("host=localhost");

            var mappedEntity = Mapper.Map<Models.Movie>(entity);
            MovieActivated message = new MovieActivated { Movie = mappedEntity };
            bus.PubSub.Publish(message);

            return mappedEntity;
        }

        public override Models.Movie Hide(int id)
        {
            var set = Context.Set<Movie>();
            var entity = set.Find(id);
            entity.StateMachine = "hidden";
            Context.SaveChanges();
            return Mapper.Map<Models.Movie>(entity);
        }

        public override List<string> AllowedActions(Movie entity)
        {
            return new List<string>() { nameof(Activate), nameof(Update), nameof(Hide) };
        }

    }
}
