using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models.DTOs
{
    public class ReservationMovieDto
    {
        public int ReservationId { get; set; }
        public DateTime ReservationDate { get; set; }
        public int ScreeningId { get; set; }
        public DateTime ScreeningDate { get; set; }
        public List<int> SeatIds { get; set; } = new List<int>();

        public int MovieId { get; set; }
        public string? MovieTitle { get; set; }
        public int? MovieDuration { get; set; }
        public string? MovieSynopsis { get; set; }
        public string? MovieImageBase64 { get; set; }
    }

}
