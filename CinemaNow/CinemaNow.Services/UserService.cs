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
using Microsoft.Extensions.Logging;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;
using Microsoft.AspNetCore.Http;
using System.Security.Claims;

namespace CinemaNow.Services
{
    public class UserService : BaseCRUDService<Models.User, UserSearchObject, Database.User, UserInsertRequest, UserUpdateRequest>, IUserService
    {
        ILogger<UserService> _logger;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public UserService(Ib200033Context context, IMapper mapper, ILogger<UserService> logger, IHttpContextAccessor httpContextAccessor) : base(context, mapper)
        {
            _logger = logger;
            _httpContextAccessor = httpContextAccessor;
        }

        public override IQueryable<Database.User> AddFilter(UserSearchObject searchObject, IQueryable<Database.User> query)
        {
            query = base.AddFilter(searchObject, query);

            if (!string.IsNullOrWhiteSpace(searchObject?.NameGTE))
                query = query.Where(x => x.Name.StartsWith(searchObject.NameGTE));

            if (!string.IsNullOrWhiteSpace(searchObject?.SurnameGTE))
                query = query.Where(x => x.Surname.StartsWith(searchObject.SurnameGTE));

            if (!string.IsNullOrWhiteSpace(searchObject?.Email))
                query = query.Where(x => x.Email == searchObject.Email);

            if (!string.IsNullOrWhiteSpace(searchObject?.Username))
                query = query.Where(x => x.Username == searchObject.Username);

            if (searchObject?.IsRoleIncluded == true)
                query = query.Include(x => x.Roles);

            return query;
        }

        public override Models.PagedResult<Models.User> GetPaged(UserSearchObject search)
        {
            var pagedData = base.GetPaged(search);

            foreach (var user in pagedData.ResultList)
            {
                var dbUser = Context.Set<Database.User>().Find(user.Id);
                if (dbUser != null)
                {
                    user.ImageBase64 = dbUser.Image != null ? Convert.ToBase64String(dbUser.Image) : null;
                }
            }

            return pagedData;
        }

        public override Models.User GetByID(int id)
        {
            var entity = Context.Users.Include(u => u.Roles).FirstOrDefault(u => u.Id == id);

            if (entity != null)
            {
                var model = Mapper.Map<Models.User>(entity);

                model.ImageBase64 = entity.Image != null
                    ? Convert.ToBase64String(entity.Image)
                    : null;

                return model;
            }
            else
                return null;
        }

        public async Task UpdateUserImage(int id, byte[] imageBytes)
        {
            var user = Context.Set<Database.User>().Find(id);
            if (user != null)
            {
                user.Image = imageBytes;
                await Context.SaveChangesAsync();
            }
        }

        public override void BeforeInsert(UserInsertRequest request, Database.User entity)
        {
            var usernameExists = Context.Users.Any(u => u.Username == request.Username);
            if (usernameExists)
            {
                throw new Exception("The username is already taken. Please choose another one.");
            }

            if (request.Password != request.PasswordConfirmation)
                throw new Exception("Password and PasswordConfirmation must be the same values.");

            entity.PasswordSalt = GenerateSalt();
            entity.PasswordHash = GenerateHash(entity.PasswordSalt, request.Password);

            foreach (var roleId in request.RoleIds)
            {
                var role = Context.Roles.FirstOrDefault(r => r.Id == roleId);
                if (role == null)
                    throw new Exception($"Role with ID {roleId} not found");

                entity.Roles.Add(role);
            }

            if (!string.IsNullOrEmpty(request.ImageBase64))
            {
                entity.Image = Convert.FromBase64String(request.ImageBase64);
            }

            base.BeforeInsert(request, entity);
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

        public override void BeforeUpdate(UserUpdateRequest request, Database.User entity)
        {
            base.BeforeUpdate(request, entity);

            var usernameExists = Context.Users.Any(u => u.Username == request.Username && u.Id != entity.Id);
            if (usernameExists)
            {
                throw new Exception("The username is already taken. Please choose another one.");
            }

            if (request.Password != null)
            {
                if (request.Password != request.PasswordConfirmation)
                    throw new Exception("Password and PasswordConfirmation must be the same values.");

                entity.PasswordSalt = GenerateSalt();
                entity.PasswordHash = GenerateHash(entity.PasswordSalt, request.Password);
            }

            if (request.RoleIds != null)
            {
                foreach (var roleId in request.RoleIds)
                {
                    var role = Context.Roles.FirstOrDefault(r => r.Id == roleId);
                    if (role == null)
                        throw new Exception($"Role with ID {roleId} not found");

                    entity.Roles.Add(role);
                }
            }

            if (!string.IsNullOrEmpty(request.ImageBase64))
            {
                entity.Image = Convert.FromBase64String(request.ImageBase64);
            }
        }

        public Models.User Login(string username, string password)
        {
            var entity = Context.Users.Include(x => x.Roles).FirstOrDefault(x => x.Username == username);

            if (entity == null)
                return null;

            var hash = GenerateHash(entity.PasswordSalt, password);

            if (hash != entity.PasswordHash)
                return null;

            return this.Mapper.Map<Models.User>(entity);
        }

        public int GetCurrentUserId()
        {
            var username = _httpContextAccessor.HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(username))
            {
                throw new UnauthorizedAccessException("User is not authenticated.");
            }

            var user = Context.Users.FirstOrDefault(u => u.Username == username);
            if (user == null)
            {
                throw new UnauthorizedAccessException("User not found.");
            }

            return user.Id;
        }

        public async Task<bool> IsUsernameTaken(string username)
        {
            return await Context.Users.AnyAsync(u => u.Username == username);
        }

        public override Models.User Update(int id, UserUpdateRequest request)
        {
            var currentUserId = GetCurrentUserId();

            if (id != currentUserId)
            {
                throw new UnauthorizedAccessException("You are not authorized to update this user's information.");
            }

            return base.Update(id, request);
        }


    }
}
