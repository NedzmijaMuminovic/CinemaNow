using System;
using System.Collections.Generic;
using System.Numerics;

namespace CinemaNow.Models.Requests
{
    public partial class MovieUpdateRequest
    {

        public string? Title { get; set; }

        public int? Duration { get; set; }

        public string? Synopsis { get; set; }
        public string? ImageBase64 { get; set; }
    }

}