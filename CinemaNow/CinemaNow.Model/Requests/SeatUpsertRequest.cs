using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models.Requests
{
    public partial class SeatUpsertRequest
    {
        public string? Name { get; set; }

        public int? ScreeningId { get; set; }

        public bool? IsReserved { get; set; }
    }
}
