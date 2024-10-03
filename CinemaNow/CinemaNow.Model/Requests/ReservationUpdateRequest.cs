using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models.Requests
{
    public class ReservationUpdateRequest
    {
        public int? ScreeningId { get; set; }
        public List<int>? SeatIds { get; set; } = new List<int>();
    }
}
