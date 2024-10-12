using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models.Reports
{
    public class MovieReservationSeatCount
    {
        public int MovieId { get; set; }
        public string MovieTitle { get; set; }
        public int ReservationSeatCount { get; set; }
    }
}
