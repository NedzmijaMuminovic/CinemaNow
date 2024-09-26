using CinemaNow.Models;
using CinemaNow.Models.Requests;
using CinemaNow.Models.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CinemaNow.Services
{
    public interface IScreeningService : IBaseCRUDService<Screening, ScreeningSearchObject, ScreeningInsertRequest, ScreeningUpdateRequest>
    {
        public Screening Activate(int id);
        public Screening Edit(int id);
        public Screening Hide(int id);
        public List<string> AllowedActions(int id);
        public List<Models.Screening> GetScreeningsByMovieId(int movieId, DateTime? date = null);
    }
}
