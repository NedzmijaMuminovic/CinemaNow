using CinemaNow.Models;
using CinemaNow.Models.Requests;
using CinemaNow.Models.SearchObjects;
using CinemaNow.Services.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using System.Linq.Dynamic.Core;

namespace CinemaNow.Services
{
    public class UserService : IUserService
    {
        public Ib200033Context Context { get; set; }
        public IMapper Mapper { get; set; }
        public UserService(Ib200033Context context, IMapper mapper) { 
            Context = context;
            Mapper = mapper;
        }

        public virtual List<Models.User> GetList(UserSearchObject searchObject)
        {
            List<Models.User> result = new List<Models.User>();

            var query = Context.Users.AsQueryable();

            if (!string.IsNullOrWhiteSpace(searchObject?.NameGTE))
                query = query.Where(x=>x.Name.StartsWith(searchObject.NameGTE));

            if (!string.IsNullOrWhiteSpace(searchObject?.SurnameGTE))
                query = query.Where(x => x.Surname.StartsWith(searchObject.SurnameGTE));

            if (!string.IsNullOrWhiteSpace(searchObject?.Email))
                query = query.Where(x => x.Email == searchObject.Email);

            if (!string.IsNullOrWhiteSpace(searchObject?.Username))
                query = query.Where(x => x.Username == searchObject.Username);

            if (searchObject?.IsRoleIncluded == true)
                query = query.Include(x => x.Roles);

            if (!string.IsNullOrWhiteSpace(searchObject?.OrderBy))
                query = query.OrderBy(searchObject.OrderBy);

            if (searchObject?.Page.HasValue == true && searchObject?.PageSize.HasValue == true) //paginacija
            query = query.Skip(searchObject.Page.Value * searchObject.PageSize.Value).Take(searchObject.PageSize.Value);

            var list = query.ToList();

            result = Mapper.Map(list, result);

            return result;
        }

        public Models.User Insert(UserInsertRequest request)
        {
            if (request.Password != request.PasswordConfirmation)
                throw new Exception("Password and PasswordConfirmation must be the same values.");

            Database.User entity = new Database.User();
            Mapper.Map(request, entity);

            entity.PasswordSalt = GenerateSalt();
            entity.PasswordHash = GenerateHash(entity.PasswordSalt, request.Password);

            Context.Add(entity);
            Context.SaveChanges();

            return Mapper.Map<Models.User>(entity);
        }

        public static string GenerateSalt()
        {
            var byteArray = RNGCryptoServiceProvider.GetBytes(16);

            return Convert.ToBase64String(byteArray);
        }
        public static string GenerateHash(string salt, string password)
        {
            byte[] src = Convert.FromBase64String(salt);
            byte[] bytes = Encoding.Unicode.GetBytes(password);
            byte[] dst = new byte[src.Length + bytes.Length];

            System.Buffer.BlockCopy(src, 0, dst, 0, src.Length);
            System.Buffer.BlockCopy(bytes, 0, dst, src.Length, bytes.Length);

            HashAlgorithm algorithm = HashAlgorithm.Create("SHA1");
            byte[] inArray = algorithm.ComputeHash(dst);
            return Convert.ToBase64String(inArray);
        }

        public Models.User Update(int id, UserUpdateRequest request)
        {
            var entity = Context.Users.Find(id);

            Mapper.Map(request, entity);

            if (request.Password != null)
            {
                if (request.Password != request.PasswordConfirmation)
                    throw new Exception("Password and PasswordConfirmation must be the same values.");

                entity.PasswordSalt = GenerateSalt();
                entity.PasswordHash = GenerateHash(entity.PasswordSalt, request.Password);
            }

            Context.SaveChanges();
            return Mapper.Map<Models.User>(entity);
        }
    }
}
