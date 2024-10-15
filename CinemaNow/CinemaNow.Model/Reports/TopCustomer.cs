using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models.Reports
{
    public class TopCustomer
    {
        public int? UserId { get; set; }
        public string? Name { get; set; }
        public string? Surname { get; set; }
        public decimal? TotalSpent { get; set; }
    }

}
