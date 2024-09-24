using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models.Requests
{
    public class ReservationUpdateRequest
    {
        public int? ScreeningId { get; set; }
        public DateTime? DateTime { get; set; }
        public int? NumberOfTickets { get; set; }
        public decimal? TotalPrice { get; set; }
        public List<int>? SeatIds { get; set; } = new List<int>();
    }
}
