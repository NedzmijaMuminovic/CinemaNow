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

        public override Models.Actor GetByID(int id)
        {
            var entity = Context.Set<Database.Actor>().Find(id);

            if (entity != null)
                return Mapper.Map<Models.Actor>(entity);
            else
                return null;
        }

    }
}
