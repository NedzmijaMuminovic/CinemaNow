using System;
using System.Collections.Generic;

namespace CinemaNow.Services.Database;

public partial class Seat
{
    public int Id { get; set; }

    public string? Name { get; set; }

    public virtual ICollection<ReservationSeat> ReservationSeats { get; set; } = new List<ReservationSeat>();

    public virtual ICollection<ScreeningSeat> ScreeningSeats { get; set; } = new List<ScreeningSeat>();
}
