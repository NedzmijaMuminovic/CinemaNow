using CinemaNow.Models.Requests;
using CinemaNow.Models.SearchObjects;
using CinemaNow.Services.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CinemaNow.Services
{
    public class ActorService : BaseCRUDService<Models.Actor, ActorSearchObject, Actor, ActorUpsertRequest, ActorUpsertRequest>, IActorService
    {
        public ActorService(Ib200033Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Actor> AddFilter(ActorSearchObject searchObject, IQueryable<Actor> query)
        {
            query = base.AddFilter(searchObject, query);

            if (!string.IsNullOrWhiteSpace(searchObject?.NameGTE))
                query = query.Where(x => x.Name.StartsWith(searchObject.NameGTE));

            if (!string.IsNullOrWhiteSpace(searchObject?.SurnameGTE))
                query = query.Where(x => x.Surname.StartsWith(searchObject.SurnameGTE));

            return query;
        }

        public override Models.PagedResult<Models.Actor> GetPaged(ActorSearchObject search)
        {
            var pagedData = base.GetPaged(search);

            foreach (var actor in pagedData.ResultList)
            {
                var dbActor = Context.Set<Database.Actor>().Find(actor.Id);
                if (dbActor != null)
                {
                    actor.ImageBase64 = dbActor.Image != null ? Convert.ToBase64String(dbActor.Image) : null;
                }
            }

            return pagedData;
        }

        public override Models.Actor GetByID(int id)
        {
            var entity = Context.Set<Database.Actor>().Find(id);

            if (entity != null)
            {
                var model = Mapper.Map<Models.Actor>(entity);

                model.ImageBase64 = entity.Image != null ? Convert.ToBase64String(entity.Image) : null;

                return model;
            }
            else
                return null;
        }

        public override void BeforeInsert(ActorUpsertRequest request, Database.Actor entity)
        {
            if (!string.IsNullOrEmpty(request.ImageBase64))
            {
                entity.Image = Convert.FromBase64String(request.ImageBase64);
            }
        }

        public override void BeforeUpdate(ActorUpsertRequest request, Database.Actor entity)
        {
            if (!string.IsNullOrEmpty(request.ImageBase64))
            {
                entity.Image = Convert.FromBase64String(request.ImageBase64);
            }
        }

    }
}
