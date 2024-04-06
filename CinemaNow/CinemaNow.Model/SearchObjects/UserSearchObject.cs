using System;
using System.Collections.Generic;
using System.Text;

namespace CinemaNow.Models.SearchObjects
{
    public class UserSearchObject
    {
        public string? NameGTE { get; set; } //gte - greater than/starts with, suprotno lte (lower)
        public string? SurnameGTE { get; set; }
        public string? Email { get; set; }
        public string? Username { get; set; }
        public bool? IsRoleIncluded { get; set; }
        public int? Page { get; set; }
        public int? PageSize { get; set; }
        public string? OrderBy { get; set; }
    }
}
