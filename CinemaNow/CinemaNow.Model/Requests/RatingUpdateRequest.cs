using System;
using System.Collections.Generic;
using System.Numerics;

namespace CinemaNow.Models.Requests
{
    public class RatingUpdateRequest
    {

        public int Value { get; set; }
        public string? Comment { get; set; }
    }

}