using CinemaNow.Models;
using CinemaNow.Models.Requests;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CinemaNow.Services.MovieStateMachine
{
    public class InitialMovieState : BaseMovieState
    {
        public InitialMovieState(Database.Ib200033Context context, IMapper mapper, IServiceProvider serviceProvider) : base(context, mapper, serviceProvider)
        {
        }

        public override Movie Insert(MovieInsertRequest request)
        {
            var set = Context.Set<Database.Movie>();
            var entity = Mapper.Map<Database.Movie>(request);
            entity.StateMachine = "draft";
            set.Add(entity);
            Context.SaveChanges();
            return Mapper.Map<Movie>(entity);
        }

        public override List<string> AllowedActions(Database.Movie entity)
        {
            return new List<string>() { nameof(Insert) };
        }

    }
}
