using CinemaNow.Models;
using CinemaNow.Models.Requests;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CinemaNow.Services.ScreeningStateMachine
{
    public class InitialScreeningState : BaseScreeningState
    {
        public InitialScreeningState(Database.Ib200033Context context, IMapper mapper, IServiceProvider serviceProvider) : base(context, mapper, serviceProvider)
        {
        }

        public override Screening Insert(ScreeningInsertRequest request)
        {
            var set = Context.Set<Database.Screening>();
            var entity = Mapper.Map<Database.Screening>(request);
            entity.StateMachine = "draft";
            set.Add(entity);
            Context.SaveChanges();
            return Mapper.Map<Screening>(entity);
        }

        public override List<string> AllowedActions(Database.Screening entity)
        {
            return new List<string>() { nameof(Insert) };
        }

    }
}
