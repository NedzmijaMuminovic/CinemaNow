using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models.SearchObjects
{
    public class MovieSearchObject : BaseSearchObject
    {
        public string? FTS { get; set; } //full text search
        public bool? IsActorIncluded { get; set; }
    }
}
