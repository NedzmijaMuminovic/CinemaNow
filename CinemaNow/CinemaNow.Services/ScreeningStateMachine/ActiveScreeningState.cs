using CinemaNow.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CinemaNow.Services.ScreeningStateMachine
{
    public class ActiveScreeningState : BaseScreeningState
    {
        public ActiveScreeningState(Ib200033Context context, IMapper mapper, IServiceProvider serviceProvider) : base(context, mapper, serviceProvider)
        {
        }

        public override Models.Screening Hide(int id)
        {
            var set = Context.Set<Screening>();
            var entity = set.Find(id);
            entity.StateMachine = "hidden";
            Context.SaveChanges();
            return Mapper.Map<Models.Screening>(entity);
        }

        public override List<string> AllowedActions(Screening entity)
        {
            return new List<string>() { nameof(Hide) };
        }

    }
}
