using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models
{
    public class Seat
    {
        public int Id { get; set; }

        public string? Name { get; set; }

        public int? ScreeningId { get; set; }

        public bool? IsReserved { get; set; }

        public Screening? Screening { get; set; }
    }
}
