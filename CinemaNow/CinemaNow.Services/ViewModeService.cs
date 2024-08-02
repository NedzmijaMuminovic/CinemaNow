using CinemaNow.Models;
using CinemaNow.Models.SearchObjects;
using CinemaNow.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Linq.Dynamic.Core;
using CinemaNow.Models.Requests;

namespace CinemaNow.Services
{
    public class ViewModeService : BaseCRUDService<Models.ViewMode, ViewModeSearchObject, Database.ViewMode, ViewModeUpsertRequest, ViewModeUpsertRequest>, IViewModeService
    {

        public ViewModeService(Ib200033Context context, IMapper mapper) : base(context, mapper) {
        }

        public override IQueryable<Database.ViewMode> AddFilter(ViewModeSearchObject search, IQueryable<Database.ViewMode> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search?.NameGTE))
                filteredQuery = filteredQuery.Where(x => x.Name.StartsWith(search.NameGTE));

            return filteredQuery;
        }

    }
}
