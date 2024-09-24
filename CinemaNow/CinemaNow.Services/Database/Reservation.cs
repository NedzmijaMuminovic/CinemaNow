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

    public virtual Screening? Screening { get; set; }

    public virtual User? User { get; set; }

    public virtual ICollection<Seat> Seats { get; set; } = new List<Seat>();
}
