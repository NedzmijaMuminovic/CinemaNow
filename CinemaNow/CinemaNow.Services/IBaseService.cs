using CinemaNow.Models.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Text;
using System.Threading.Tasks;

namespace CinemaNow.Services
{
    public interface IBaseService<TModel, TSearch> where TSearch : BaseSearchObject
    {
        public Models.PagedResult<TModel> GetPaged(TSearch search);
        public TModel GetByID(int id);
    }
}
