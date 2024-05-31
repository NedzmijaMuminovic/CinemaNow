using CinemaNow.Models;
using CinemaNow.Models.Requests;
using CinemaNow.Services.Database;
using MapsterMapper;
using Microsoft.Extensions.DependencyInjection;

namespace CinemaNow.Services.ScreeningStateMachine
{
    public class BaseScreeningState
    { 
        //initial, draft, active, hidden
        public Ib200033Context Context { get; set; }
        public IMapper Mapper { get; set; }
        public IServiceProvider ServiceProvider { get; set; }

        public BaseScreeningState(Ib200033Context context, IMapper mapper, IServiceProvider serviceProvider)
        {
            Context = context;
            Mapper = mapper;
            ServiceProvider = serviceProvider;
        }

        public virtual Models.Screening Insert(ScreeningInsertRequest request)
        {
            throw new UserException("Method not allowed");
        }

        public virtual Models.Screening Update(int id, ScreeningUpdateRequest request)
        {
            throw new UserException("Method not allowed");
        }

        public virtual Models.Screening Activate(int id)
        {
            throw new UserException("Method not allowed");
        }

        public virtual Models.Screening Hide(int id)
        {
            throw new UserException("Method not allowed");
        }

        public virtual Models.Screening Edit(int id)
        {
            throw new UserException("Method not allowed");
        }

        public virtual List<string> AllowedActions(Database.Screening entity)
        {
            throw new UserException("Method not allowed");
        }

        public BaseScreeningState CreateState(string stateName)
        {
            switch (stateName)
            {
                case "initial":
                    return ServiceProvider.GetService<InitialScreeningState>();
                case "draft":
                    return ServiceProvider.GetService<DraftScreeningState>();
                case "active":
                    return ServiceProvider.GetService<ActiveScreeningState>();
                case "hidden":
                    return ServiceProvider.GetService<HiddenScreeningState>();
                default: throw new Exception("State not recognised");
            }
        }

    }
}
