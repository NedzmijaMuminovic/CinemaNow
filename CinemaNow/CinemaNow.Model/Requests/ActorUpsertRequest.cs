using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models.Requests
{
    public class ActorUpsertRequest
    {
        public string Name { get; set; }

        public string Surname { get; set; }
        public List<int>? MovieIds { get; set; }
    }
}