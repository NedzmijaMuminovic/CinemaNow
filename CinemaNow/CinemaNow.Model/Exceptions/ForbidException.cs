using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models.Exceptions
{
    public class ForbidException : Exception
    {
        public ForbidException(string message) : base(message) { }
    }
}
