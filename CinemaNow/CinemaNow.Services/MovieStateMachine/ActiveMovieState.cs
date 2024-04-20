using CinemaNow.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CinemaNow.Services.MovieStateMachine
{
    public class ActiveMovieState : BaseMovieState
    {
        public ActiveMovieState(Ib200033Context context, IMapper mapper, IServiceProvider serviceProvider) : base(context, mapper, serviceProvider)
        {
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
            return new List<string>() { nameof(Hide) };
        }

    }
}
