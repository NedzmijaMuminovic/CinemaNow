using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models.MachineLearningModels
{
    public class MoviePrediction
    {
        public int MovieId { get; set; }
        public float Score { get; set; }
        public string Title { get; set; }
    }
}
