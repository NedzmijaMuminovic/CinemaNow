﻿using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models.SearchObjects
{
    public class ScreeningSearchObject : BaseSearchObject
    {
        public string? FTS { get; set; }
        public bool? IsMovieIncluded { get; set; }
        public bool? IsHallIncluded { get; set; }
        public bool? IsViewModeIncluded { get; set; }
        public DateTime? Date { get; set; }
    }
}
