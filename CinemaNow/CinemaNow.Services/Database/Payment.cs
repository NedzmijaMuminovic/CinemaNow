using System;
using System.Collections.Generic;

namespace CinemaNow.Services.Database;

public partial class Payment
{
    public int Id { get; set; }

    public int? UserId { get; set; }

    public string? Provider { get; set; }

    public string? TransactionId { get; set; }

    public decimal? Amount { get; set; }

    public DateTime? DateTime { get; set; }

    public string? Status { get; set; }

    public virtual ICollection<Reservation> Reservations { get; set; } = new List<Reservation>();

    public virtual User? User { get; set; }
}
