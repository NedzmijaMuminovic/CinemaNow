using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models
{
    public class Rating
    {
        public int Id { get; set; }

        public int? UserId { get; set; }

        public int? MovieId { get; set; }

        public int? Value { get; set; }

        public string? Comment { get; set; }

        public virtual Movie Movie { get; set; }

        public virtual User User { get; set; }
    }
}
