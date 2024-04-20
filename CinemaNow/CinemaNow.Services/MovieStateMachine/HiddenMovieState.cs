using CinemaNow.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CinemaNow.Services.MovieStateMachine
{
    public class HiddenMovieState : BaseMovieState
    {
        public HiddenMovieState(Ib200033Context context, IMapper mapper, IServiceProvider serviceProvider) : base(context, mapper, serviceProvider)
        {
        }

        public override Models.Movie Edit(int id)
        {
            var set = Context.Set<Movie>();
            var entity = set.Find(id);
            entity.StateMachine = "draft";
            Context.SaveChanges();
            return Mapper.Map<Models.Movie>(entity);
        }

        public override Models.Movie Activate(int id)
        {
            var set = Context.Set<Movie>();
            var entity = set.Find(id);
            entity.StateMachine = "active";
            Context.SaveChanges();
            return Mapper.Map<Models.Movie>(entity);
        }

        public override List<string> AllowedActions(Movie entity)
        {
            return new List<string>() { nameof(Edit), nameof(Activate) };
        }

    }
}
