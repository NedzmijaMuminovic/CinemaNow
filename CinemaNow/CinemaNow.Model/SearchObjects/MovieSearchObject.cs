using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models.SearchObjects
{
    public class MovieSearchObject
    {
        public string? FTS { get; set; } //full text search
        public int? Page { get; set; }
        public int? PageSize { get; set; }
        public string? OrderBy { get; set; }
    }
}
