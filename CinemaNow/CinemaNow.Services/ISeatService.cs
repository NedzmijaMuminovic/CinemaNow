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
    public interface ISeatService : IBaseCRUDService<Seat, SeatSearchObject, SeatUpsertRequest, SeatUpsertRequest>
    {
    }
}
