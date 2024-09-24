using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models
{
    public class ReservationSeat
    {
        public int ReservationId { get; set; }
        public int SeatId { get; set; }

        public Seat? Seat { get; set; }
    }
}
