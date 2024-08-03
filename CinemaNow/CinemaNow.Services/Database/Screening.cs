using System;
using System.Collections.Generic;

namespace CinemaNow.Services.Database;

public partial class Screening
{
    public int Id { get; set; }

    public int? MovieId { get; set; }

    public int? HallId { get; set; }

    public int? ViewModeId { get; set; }

    public DateTime? DateTime { get; set; }

    public decimal? Price { get; set; }

    public string? StateMachine { get; set; }

    public virtual Hall Hall { get; set; }

    public virtual Movie Movie { get; set; }

    public virtual ICollection<Purchase> Purchases { get; set; } = new List<Purchase>();

    public virtual ICollection<Reservation> Reservations { get; set; } = new List<Reservation>();

    public virtual ICollection<Seat> Seats { get; set; } = new List<Seat>();

    public virtual ViewMode ViewMode { get; set; }
}
