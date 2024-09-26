using CinemaNow.Models.Requests;
using CinemaNow.Models.SearchObjects;
using CinemaNow.Services.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using CinemaNow.Services.ScreeningStateMachine;
using Azure.Core;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace CinemaNow.Services
{
    public class ScreeningService : BaseCRUDService<Models.Screening, ScreeningSearchObject, Database.Screening, ScreeningInsertRequest, ScreeningUpdateRequest>, IScreeningService
    {
        public BaseScreeningState BaseScreeningState { get; set; }
        ILogger<ScreeningService> _logger;

        public ScreeningService(Ib200033Context context, IMapper mapper, BaseScreeningState baseScreeningState, ILogger<ScreeningService> logger) : base(context, mapper)
        {
            BaseScreeningState = baseScreeningState;
            _logger = logger;
        }

        public override IQueryable<Screening> AddFilter(ScreeningSearchObject search, IQueryable<Screening> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search?.FTS))
                filteredQuery = filteredQuery.Where(x => x.Movie.Title.Contains(search.FTS));

            if (search?.IsMovieIncluded == true)
            {
                filteredQuery = filteredQuery.Include(x => x.Movie)
                                             .ThenInclude(movie => movie.Genres);
            }

            if (search?.IsHallIncluded == true)
                filteredQuery = filteredQuery.Include(x => x.Hall);

            if (search?.IsViewModeIncluded == true)
                filteredQuery = filteredQuery.Include(x => x.ViewMode);

            if (search?.Date.HasValue == true)
                filteredQuery = filteredQuery.Where(x => x.DateTime.HasValue && x.DateTime.Value.Date == search.Date.Value.Date);

            return filteredQuery;
        }

        public override Models.Screening GetByID(int id)
        {
            var entity = Context.Screenings.Include(s => s.Movie).Include(s => s.Hall).Include(s=>s.ViewMode).FirstOrDefault(s => s.Id == id);

            if (entity != null)
            {
                var model = Mapper.Map<Models.Screening>(entity);

                if (entity.Movie != null)
                {
                    model.Movie.ImageBase64 = entity.Movie.Image != null ? Convert.ToBase64String(entity.Movie.Image) : null;
                }

                return model;
            }
            return null;
        }

        public override Models.PagedResult<Models.Screening> GetPaged(ScreeningSearchObject search)
        {
            var pagedData = base.GetPaged(search);

            foreach (var screening in pagedData.ResultList)
            {
                if (search?.IsMovieIncluded == true)
                {
                    var dbScreening = Context.Screenings.Include(s => s.Movie).FirstOrDefault(s => s.Id == screening.Id);
                    if (dbScreening?.Movie != null)
                    {
                        screening.Movie.ImageBase64 = dbScreening.Movie.Image != null ? Convert.ToBase64String(dbScreening.Movie.Image) : null;
                    }
                }
            }

            return pagedData;
        }

        public override void BeforeInsert(ScreeningInsertRequest request, Screening entity)
        {
            var movie = Context.Movies.FirstOrDefault(m => m.Id == request.MovieId);
            if (movie == null)
                throw new Exception("Movie not found");

            var hall = Context.Halls.FirstOrDefault(h => h.Id == request.HallId);
            if (hall == null)
                throw new Exception("Hall not found");

            var viewMode = Context.ViewModes.FirstOrDefault(vm => vm.Id == request.ViewModeId);
            if (viewMode == null)
                throw new Exception("ViewMode not found");

            base.BeforeInsert(request, entity);
        }

        public override void BeforeUpdate(ScreeningUpdateRequest request, Screening entity)
        {
            base.BeforeUpdate(request, entity);

            var movie = Context.Movies.FirstOrDefault(m => m.Id == request.MovieId);
            if (movie == null)
                throw new Exception("Movie not found");

            var hall = Context.Halls.FirstOrDefault(h => h.Id == request.HallId);
            if (hall == null)
                throw new Exception("Hall not found");

            var viewMode = Context.ViewModes.FirstOrDefault(vm => vm.Id == request.ViewModeId);
            if (viewMode == null)
                throw new Exception("ViewMode not found");
        }

        public override Models.Screening Insert(ScreeningInsertRequest request)
        {
            var state = BaseScreeningState.CreateState("initial");
            var insertedScreening = state.Insert(request);

            var entity = Context.Screenings.Include(s => s.Movie).Include(s => s.Hall).Include(s => s.ViewMode).FirstOrDefault(s => s.Id == insertedScreening.Id);
            return Mapper.Map<Models.Screening>(entity);
        }

        public override Models.Screening Update(int id, ScreeningUpdateRequest request)
        {
            var entity = GetByID(id);
            var state = BaseScreeningState.CreateState(entity.StateMachine);
            var updatedScreening = state.Update(id, request);

            var updatedEntity = Context.Screenings.Include(s => s.Movie).Include(s => s.Hall).Include(s => s.ViewMode).FirstOrDefault(s => s.Id == updatedScreening.Id);
            return Mapper.Map<Models.Screening>(updatedEntity);
        }

        public Models.Screening Activate(int id)
        {
            var entity = GetByID(id);
            var state = BaseScreeningState.CreateState(entity.StateMachine);
            return state.Activate(id);
        }

        public Models.Screening Edit(int id)
        {
            var entity = GetByID(id);
            var state = BaseScreeningState.CreateState(entity.StateMachine);
            return state.Edit(id);
        }

        public Models.Screening Hide(int id)
        {
            var entity = GetByID(id);
            var state = BaseScreeningState.CreateState(entity.StateMachine);
            return state.Hide(id);
        }

        public List<string> AllowedActions(int id)
        {
            _logger.LogInformation($"Allowed actions called for: {id}");
            if (id <= 0)
            {
                var state = BaseScreeningState.CreateState("initial");
                return state.AllowedActions(null);
            }
            else
            {
                var entity = Context.Screenings.Find(id);
                var state = BaseScreeningState.CreateState(entity.StateMachine);
                return state.AllowedActions(entity);
            }
        }

        public List<Models.Screening> GetScreeningsByMovieId(int movieId)
        {
            var query = Context.Screenings
                .Include(s => s.Movie)
                .Include(s => s.Hall)
                .Include(s => s.ViewMode)
                .Where(s => s.MovieId == movieId && s.StateMachine == "Active")
                .OrderBy(s => s.DateTime);

            var screenings = query.ToList();
            return Mapper.Map<List<Models.Screening>>(screenings);
        }
    }
}
