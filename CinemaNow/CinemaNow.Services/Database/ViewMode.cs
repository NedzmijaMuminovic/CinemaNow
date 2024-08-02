using System;
using System.Collections.Generic;

namespace CinemaNow.Services.Database;

public partial class ViewMode
{
    public int Id { get; set; }

    public string? Name { get; set; }

    public virtual ICollection<Screening> Screenings { get; set; } = new List<Screening>();
}
