using CinemaNow.Models;
using CinemaNow.Models.DTOs;
using CinemaNow.Models.Requests;
using CinemaNow.Models.SearchObjects;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CinemaNow.Services
{
    public interface IReservationService : IBaseCRUDService<Reservation, ReservationSearchObject, ReservationInsertRequest, ReservationUpdateRequest>
    {
        List<ReservationMovieDto> GetReservationsByUserId(int userId);
        string GenerateQRCode(int reservationId);
    }
}
