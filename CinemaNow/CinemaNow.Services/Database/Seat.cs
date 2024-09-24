using System;
using System.Collections.Generic;

namespace CinemaNow.Services.Database;

public partial class Seat
{
    public int Id { get; set; }

    public string? Name { get; set; }

    public virtual ICollection<ScreeningSeat> ScreeningSeats { get; set; } = new List<ScreeningSeat>();

    public virtual ICollection<Reservation> Reservations { get; set; } = new List<Reservation>();
}
