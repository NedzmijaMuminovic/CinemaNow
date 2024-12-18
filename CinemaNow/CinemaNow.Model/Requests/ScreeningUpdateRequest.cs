﻿using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models.Requests
{
    public partial class ScreeningUpdateRequest
    {
        public int MovieId { get; set; }
        public int HallId { get; set; }
        public int ViewModeId { get; set; }

        public DateTime DateTime { get; set; }

        public decimal Price { get; set; }
    }
}
