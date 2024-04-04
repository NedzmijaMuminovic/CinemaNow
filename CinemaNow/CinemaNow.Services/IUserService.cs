using CinemaNow.Models;
using CinemaNow.Models.Requests;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CinemaNow.Services
{
    public interface IUserService
    {
        List<User> GetList();
        User Insert(UserInsertRequest request);
    }
}
