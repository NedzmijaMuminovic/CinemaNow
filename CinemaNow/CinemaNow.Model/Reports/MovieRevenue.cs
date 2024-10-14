using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models.Reports
{
    public class MovieRevenue
    {
        public int MovieId { get; set; }
        public string MovieTitle { get; set; }
        public decimal TotalRevenue { get; set; }
    }
}
