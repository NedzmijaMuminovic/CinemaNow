using CinemaNow.Models.Requests;
using CinemaNow.Models.SearchObjects;
using CinemaNow.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CinemaNow.Services
{
    public class RoleService : BaseCRUDService<Models.Role, RoleSearchObject, Database.Role, RoleUpsertRequest, RoleUpsertRequest>, IRoleService
    {
        public RoleService(Ib200033Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Database.Role> AddFilter(RoleSearchObject search, IQueryable<Database.Role> query)
        {
            var filteredQuery = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search?.NameGTE))
                filteredQuery = filteredQuery.Where(x => x.Name.StartsWith(search.NameGTE));

            return filteredQuery;
        }
    }
}
