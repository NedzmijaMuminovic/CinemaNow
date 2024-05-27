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
    public class ScreeningService : BaseCRUDService<Models.Screening, ScreeningSearchObject, Database.Screening, ScreeningInsertRequest, ScreeningUpdateRequest>, IScreeningService
    {
        public ScreeningService(Ib200033Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Screening> AddFilter(ScreeningSearchObject search, IQueryable<Screening> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search?.FTS))
                filteredQuery = filteredQuery.Where(x => x.Movie.Title.Contains(search.FTS));

            if (search?.IsMovieIncluded == true)
                filteredQuery = filteredQuery.Include(x => x.Movie);

            return filteredQuery;
        }

        public override Models.Screening GetByID(int id)
        {
            var entity = Context.Screenings.Include(s => s.Movie).FirstOrDefault(s => s.Id == id);

            if (entity != null)
                return Mapper.Map<Models.Screening>(entity);
            else
                return null;
        }

        public override void BeforeInsert(ScreeningInsertRequest request, Screening entity)
        {
            var movie = Context.Movies.FirstOrDefault(m => m.Id == request.MovieId);
            if (movie == null)
                throw new Exception("Movie not found");

            base.BeforeInsert(request, entity);
        }

        public override void BeforeUpdate(ScreeningUpdateRequest request, Screening entity)
        {
            base.BeforeUpdate(request, entity);

            var movie = Context.Movies.FirstOrDefault(m => m.Id == request.MovieId);
            if (movie == null)
                throw new Exception("Movie not found");
        }
    }
}
