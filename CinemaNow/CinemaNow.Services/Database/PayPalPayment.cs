using System;
using System.Collections.Generic;

namespace CinemaNow.Services.Database;

public partial class PayPalPayment
{
    public int Id { get; set; }

    public int? UserId { get; set; }

    public string? Info { get; set; }

    public virtual ICollection<Purchase> Purchases { get; set; } = new List<Purchase>();

    public virtual User User { get; set; }
}
