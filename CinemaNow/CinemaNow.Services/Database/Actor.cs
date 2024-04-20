using System;
using System.Collections.Generic;

namespace CinemaNow.Services.Database;

public partial class Actor
{
    public int Id { get; set; }

    public string Name { get; set; }

    public string Surname { get; set; }

    public byte[] Image { get; set; }

    public byte[] ImageThumb { get; set; }

    public virtual ICollection<Movie> Movies { get; set; } = new List<Movie>();
}
