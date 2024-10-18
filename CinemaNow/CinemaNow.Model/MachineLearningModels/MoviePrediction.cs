using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models.MachineLearningModels
{
    public class MoviePrediction
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string? ImageBase64 { get; set; }
        public float Score { get; set; }
    }
}
