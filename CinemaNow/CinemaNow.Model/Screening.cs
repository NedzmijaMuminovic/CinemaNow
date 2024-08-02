using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models
{
    public class Screening
    {
        public int Id { get; set; }

        public int? MovieId { get; set; }
        public int? HallId { get; set; }
        public int? ViewModeId { get; set; }

        public DateTime? Date { get; set; }

        public TimeSpan? Time { get; set; }

        public decimal? Price { get; set; }

        public Movie? Movie { get; set; }
        public Hall? Hall { get; set; }
        public ViewMode? ViewMode { get; set; }
        public string? StateMachine { get; set; }
    }
}
