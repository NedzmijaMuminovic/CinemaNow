using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models.DTOs
{
    public class SeatDto
    {
        public int Id { get; set; }
        public string? Name { get; set; }
        public bool? IsReserved { get; set; }
    }

}
