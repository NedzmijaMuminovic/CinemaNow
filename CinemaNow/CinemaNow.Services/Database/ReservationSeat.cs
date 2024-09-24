using System;
using System.Collections.Generic;

namespace CinemaNow.Services.Database;

public partial class ReservationSeat
{
    public int ReservationId { get; set; }

    public int SeatId { get; set; }

    public DateTime? ReservedAt { get; set; }

    public virtual Reservation Reservation { get; set; } = null!;

    public virtual Seat Seat { get; set; } = null!;
}
