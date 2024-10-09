using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models
{
    public class Reservation
    {
        public int Id { get; set; }
        public int? UserId { get; set; }
        public int? ScreeningId { get; set; }
        public DateTime? DateTime { get; set; }
        public int? NumberOfTickets { get; set; }
        public decimal? TotalPrice { get; set; }
        public int? PaymentId { get; set; }
        public string? PaymentType { get; set; }
        public List<ReservationSeat>? Seats { get; set; } = new List<ReservationSeat>();
        public User? User { get; set; }
        public Screening? Screening { get; set; }
        public Payment? Payment { get; set; }
        public string? QRCodeBase64 { get; set; }
    }
}
