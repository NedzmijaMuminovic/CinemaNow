using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models.MachineLearningModels
{
    public class MovieData
    {
        public int MovieId { get; set; }
        public string Title { get; set; }
        public string[] Genres { get; set; }
        public string[] Actors { get; set; }
    }
}
