using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models.Requests
{
    public partial class ScreeningUpdateRequest
    {
        public int? MovieId { get; set; }

        public DateTime? Date { get; set; }

        public TimeSpan? Time { get; set; }

        public string? Hall { get; set; }

        public decimal? Price { get; set; }
    }
}
