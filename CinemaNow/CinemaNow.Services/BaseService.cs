using CinemaNow.Models.SearchObjects;
using CinemaNow.Models;
using CinemaNow.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Text;
using System.Threading.Tasks;

namespace CinemaNow.Services
{
    public abstract class BaseService<TModel, TSearch, TDbEntity> : IBaseService<TModel, TSearch> where TSearch: BaseSearchObject where TDbEntity : class where TModel : class
    {
        public Ib200033Context Context { get; set; }
        public IMapper Mapper { get; set; }

        public BaseService(Ib200033Context context, IMapper mapper)
        {
            Context = context;
            Mapper = mapper;
        }

        public virtual Models.PagedResult<TModel> GetPaged(TSearch search)
        {
            List<TModel> result = new List<TModel>();

            var query = Context.Set<TDbEntity>().AsQueryable();

            query = AddFilter(search, query);

            int count = query.Count();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true) //paginacija
                query = query.Skip(search.Page.Value * search.PageSize.Value).Take(search.PageSize.Value);

            if (!string.IsNullOrWhiteSpace(search?.OrderBy))
                query = query.OrderBy(search.OrderBy);

            var list = query.ToList();

            result = Mapper.Map(list, result);

            Models.PagedResult<TModel> pagedResult = new Models.PagedResult<TModel>();
            pagedResult.ResultList = result;
            pagedResult.Count = count;
            return pagedResult;
        }

        public virtual IQueryable<TDbEntity> AddFilter(TSearch search, IQueryable<TDbEntity> query)
        {
            return query;
        }

        public virtual TModel GetByID(int id)
        {
            var entity = Context.Set<TDbEntity>().Find(id);

            if (entity != null)
                return Mapper.Map<TModel>(entity);
            else
                return null;
        }
    }
}
