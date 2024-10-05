using System;
using System.Collections.Generic;

namespace CinemaNow.Services.Database;

public partial class Reservation
{
    public int Id { get; set; }

    public int? UserId { get; set; }

    public int? ScreeningId { get; set; }

    public DateTime? DateTime { get; set; }

    public int? NumberOfTickets { get; set; }

    public decimal? TotalPrice { get; set; }

    public int? PaymentId { get; set; }

    public string? PaymentType { get; set; }

    public virtual Payment? Payment { get; set; }

    public virtual ICollection<ReservationSeat> ReservationSeats { get; set; } = new List<ReservationSeat>();

    public virtual Screening? Screening { get; set; }

    public virtual User? User { get; set; }
}
