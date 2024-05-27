using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models.SearchObjects
{
    public class ActorSearchObject: BaseSearchObject
    {
        public string? NameGTE { get; set; }
        public string? SurnameGTE { get; set; }
        public bool? IsMovieIncluded { get; set; }
    }
}
