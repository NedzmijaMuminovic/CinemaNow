using System;
using System.Collections.Generic;
using System.Numerics;

namespace CinemaNow.Models.Requests
{
    public partial class MovieInsertRequest
    {

        public string Title { get; set; }

        public int Duration { get; set; }

        public string Synopsis { get; set; }
        public string? ImageBase64 { get; set; }
        public List<int> ActorIds { get; set; } = new List<int>();
        public List<int> GenreIds { get; set; } = new List<int>();
    }

}