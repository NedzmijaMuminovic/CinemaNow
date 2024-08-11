using CinemaNow.Models.Requests;
using CinemaNow.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CinemaNow.Services.ScreeningStateMachine
{
    public class HiddenScreeningState : BaseScreeningState
    {
        public HiddenScreeningState(Ib200033Context context, IMapper mapper, IServiceProvider serviceProvider) : base(context, mapper, serviceProvider)
        {
        }

        public override Models.Screening Edit(int id)
        {
            var set = Context.Set<Screening>();
            var entity = set.Find(id);
            entity.StateMachine = "draft";
            Context.SaveChanges();
            return Mapper.Map<Models.Screening>(entity);
        }

        public override Models.Screening Activate(int id)
        {
            var set = Context.Set<Screening>();
            var entity = set.Find(id);
            entity.StateMachine = "active";
            Context.SaveChanges();
            return Mapper.Map<Models.Screening>(entity);
        }

        public override Models.Screening Update(int id, ScreeningUpdateRequest request)
        {
            var set = Context.Set<Screening>();
            var entity = set.Find(id);
            Mapper.Map(request, entity);
            Context.SaveChanges();
            return Mapper.Map<Models.Screening>(entity);
        }

        public override List<string> AllowedActions(Screening entity)
        {
            return new List<string>() { nameof(Edit), nameof(Activate) };
        }

    }
}
