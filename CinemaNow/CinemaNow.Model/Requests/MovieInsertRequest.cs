﻿using System;
using System.Collections.Generic;
using System.Numerics;

namespace CinemaNow.Models.Requests
{
    public partial class MovieInsertRequest
    {

        public string Title { get; set; }

        public int Duration { get; set; }

        public string Synopsis { get; set; }
    }

}