using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models
{
    public class Movie
    {
        public int Id { get; set; }
        public string? Title { get; set; }
        public int? Duration { get; set; }

        public string? Synopsis { get; set; }
    }
}
