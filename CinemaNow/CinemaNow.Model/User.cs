using System;
using System.Collections.Generic;
using System.Data;

namespace CinemaNow.Models
{
    public partial class User
    {
        public int Id { get; set; }

        public string? Name { get; set; }

        public string? Surname { get; set; }

        public string? Email { get; set; }

        public string? Username { get; set; }
        public virtual ICollection<Role> Roles { get; set; } = new List<Role>();
    }
}