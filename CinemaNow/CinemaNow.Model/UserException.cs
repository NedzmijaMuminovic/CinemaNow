using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models
{
    public class UserException : Exception
    {
        public UserException(string message): base(message) { }
    }
}
