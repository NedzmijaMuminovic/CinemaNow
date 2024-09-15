using System;
using System.Collections.Generic;
using System.Numerics;

namespace CinemaNow.Models.Requests
{
    public class RatingInsertRequest
    {
        public int UserId { get; set; }
        public int MovieId { get; set; }
        public int Value { get; set; }
        public string? Comment { get; set; }
    }

}