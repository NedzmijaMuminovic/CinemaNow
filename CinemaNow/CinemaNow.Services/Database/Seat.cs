using System;
using System.Collections.Generic;

namespace CinemaNow.Services.Database;

public partial class Seat
{
    public int Id { get; set; }

    public string? Name { get; set; }

    public int? ScreeningId { get; set; }

    public bool? IsReserved { get; set; }

    public virtual ICollection<Purchase> Purchases { get; set; } = new List<Purchase>();

    public virtual ICollection<Reservation> Reservations { get; set; } = new List<Reservation>();

    public virtual Screening Screening { get; set; }
}
