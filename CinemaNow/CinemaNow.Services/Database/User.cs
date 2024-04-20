using System;
using System.Collections.Generic;

namespace CinemaNow.Services.Database;

public partial class User
{
    public int Id { get; set; }

    public string Name { get; set; }

    public string Surname { get; set; }

    public string Email { get; set; }

    public string Username { get; set; }

    public string PasswordSalt { get; set; }

    public string PasswordHash { get; set; }

    public byte[] Image { get; set; }

    public byte[] ImageThumb { get; set; }

    public virtual ICollection<PayPalPayment> PayPalPayments { get; set; } = new List<PayPalPayment>();

    public virtual ICollection<Purchase> Purchases { get; set; } = new List<Purchase>();

    public virtual ICollection<Rating> Ratings { get; set; } = new List<Rating>();

    public virtual ICollection<Reservation> Reservations { get; set; } = new List<Reservation>();

    public virtual ICollection<Role> Roles { get; set; } = new List<Role>();
}
