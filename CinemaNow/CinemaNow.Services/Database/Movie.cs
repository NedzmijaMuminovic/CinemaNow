using System;
using System.Collections.Generic;

namespace CinemaNow.Services.Database;

public partial class Movie
{
    public int Id { get; set; }

    public string Title { get; set; }

    public int Duration { get; set; }

    public string Synopsis { get; set; }

    public byte[]? Image { get; set; }

    public byte[]? ImageThumb { get; set; }

    public string? StateMachine { get; set; }

    public virtual ICollection<Rating> Ratings { get; set; } = new List<Rating>();

    public virtual ICollection<Screening> Screenings { get; set; } = new List<Screening>();

    public virtual ICollection<Actor> Actors { get; set; } = new List<Actor>();

    public virtual ICollection<Genre> Genres { get; set; } = new List<Genre>();
}
