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
            Console.WriteLine("BeforeInsert method called");
            var movie = Context.Movies.FirstOrDefault(m => m.Id == request.MovieId);
            if (movie == null)
                throw new Exception("Movie not found");

            base.BeforeInsert(request, entity);
        }

        public override void BeforeUpdate(ScreeningUpdateRequest request, Screening entity)
        {
            Console.WriteLine("BeforeUpdate method called");
            base.BeforeUpdate(request, entity);

            var movie = Context.Movies.FirstOrDefault(m => m.Id == request.MovieId);
            if (movie == null)
                throw new Exception("Movie not found");
        }

        public override Models.Screening Insert(ScreeningInsertRequest request)
        {
            var state = BaseScreeningState.CreateState("initial");
            return state.Insert(request);
        }

        public override Models.Screening Update(int id, ScreeningUpdateRequest request)
        {
            var entity = GetByID(id);
            var state = BaseScreeningState.CreateState(entity.StateMachine);
            return state.Update(id, request);
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
    }
}
