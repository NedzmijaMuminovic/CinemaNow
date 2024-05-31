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

namespace CinemaNow.Services.ScreeningStateMachine
{
    public class DraftScreeningState : BaseScreeningState
    {
        public DraftScreeningState(Ib200033Context context, IMapper mapper, IServiceProvider serviceProvider) : base(context, mapper, serviceProvider)
        {
        }

        public override Models.Screening Update(int id, ScreeningUpdateRequest request)
        {
            var set = Context.Set<Screening>();
            var entity = set.Find(id);
            Mapper.Map(request, entity);
            Context.SaveChanges();
            return Mapper.Map<Models.Screening>(entity);
        }

        public override Models.Screening Activate(int id)
        {
            var set = Context.Set<Screening>();
            var entity = set.Find(id);
            entity.StateMachine = "active";
            Context.SaveChanges();

            var bus = RabbitHutch.CreateBus("host=localhost");

            var mappedEntity = Mapper.Map<Models.Screening>(entity);
            //ScreeningActivated message = new ScreeningActivated { Screening = mappedEntity };
            //bus.PubSub.Publish(message);

            return mappedEntity;
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
            return new List<string>() { nameof(Activate), nameof(Update), nameof(Hide) };
        }

    }
}
