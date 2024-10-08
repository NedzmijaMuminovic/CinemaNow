using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models.SearchObjects
{
    public class ReservationSearchObject : BaseSearchObject
    {
        public int? ScreeningId { get; set; }
        public int? UserId { get; set; }
        public bool? IsUserIncluded { get; set; }
        public bool? IsScreeningIncluded { get; set; }
        public bool? AreSeatsIncluded { get; set; }
        public bool? IsPaymentIncluded { get; set; }
    }
}
