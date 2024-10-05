using System;
using System.Collections.Generic;

namespace CinemaNow.Models
{
    public class Payment
    {
        public int Id { get; set; }
        public string? Provider { get; set; }
        public string? TransactionId { get; set; }
        public decimal? Amount { get; set; }
        public DateTime? DateTime { get; set; }
    }
}