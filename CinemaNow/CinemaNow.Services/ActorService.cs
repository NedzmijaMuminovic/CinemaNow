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

            if (searchObject?.IsMovieIncluded == true)
                query = query.Include(x => x.Movies);

            return query;
        }

        public override Models.Actor GetByID(int id)
        {
            var entity = Context.Actors.Include(u => u.Movies).FirstOrDefault(m => m.Id == id);

            if (entity != null)
                return Mapper.Map<Models.Actor>(entity);
            else
                return null;
        }

        public override void BeforeInsert(ActorUpsertRequest request, Actor entity)
        {
            foreach (var movieId in request.MovieIds)
            {
                var movie = Context.Movies.FirstOrDefault(m => m.Id == movieId);
                if (movie == null)
                    throw new Exception($"Movie with ID {movieId} not found");

                entity.Movies.Add(movie);
            }

            base.BeforeInsert(request, entity);
        }

        public override void BeforeUpdate(ActorUpsertRequest request, Actor entity)
        {
            base.BeforeUpdate(request, entity);

            foreach (var movieId in request.MovieIds)
            {
                var movie = Context.Movies.FirstOrDefault(m => m.Id == movieId);
                if (movie == null)
                    throw new Exception($"Movie with ID {movieId} not found");

                entity.Movies.Add(movie);
            }
        }
    }
}
