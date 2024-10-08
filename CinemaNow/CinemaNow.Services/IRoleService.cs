﻿using CinemaNow.Models;
using CinemaNow.Models.Requests;
using CinemaNow.Models.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CinemaNow.Services
{
    public interface IRoleService : IBaseCRUDService<Role, RoleSearchObject, RoleUpsertRequest, RoleUpsertRequest>
    {
    }
}
