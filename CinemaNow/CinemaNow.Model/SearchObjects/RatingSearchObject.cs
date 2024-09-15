using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models.SearchObjects
{
    public class RatingSearchObject : BaseSearchObject
    {
        public int? Value { get; set; }
        public bool? IsUserIncluded { get; set; }
        public bool? IsMovieIncluded { get; set; }
    }
}
