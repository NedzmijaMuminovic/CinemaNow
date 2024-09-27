using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models.DTOs
{
    public class SeatDto
    {
        public int SeatId { get; set; }
        public string? SeatName { get; set; }
        public bool? IsReserved { get; set; }
    }

}
