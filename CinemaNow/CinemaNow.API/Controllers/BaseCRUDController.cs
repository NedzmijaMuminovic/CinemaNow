using CinemaNow.Models.Requests;
using CinemaNow.Models.SearchObjects;
using CinemaNow.Services;
using Microsoft.AspNetCore.Mvc;

namespace CinemaNow.API.Controllers
{
    public class BaseCRUDController<TModel, TSearch, TInsert, TUpdate> : BaseController<TModel, TSearch> where TSearch : BaseSearchObject where TModel : class
    {
        public BaseCRUDController(ICRUDService<TModel, TSearch, TInsert, TUpdate> service) : base(service)
        {
        }

        [HttpPost]
        public TModel Insert(TInsert request)
        {
            return (_service as ICRUDService<TModel, TSearch, TInsert, TUpdate>).Insert(request);
        }

        [HttpPut("{id}")]
        public TModel Update(int id, TUpdate request)
        {
            return (_service as ICRUDService<TModel, TSearch, TInsert, TUpdate>).Update(id, request);
        }

    }
}
