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
using RabbitMQ.Client;
using CinemaNow.Models.Messages;
using System.Text.Json;
using System.Xml.Linq;
using Mapster;

namespace CinemaNow.Services
{
    public class UserService : BaseCRUDService<Models.User, UserSearchObject, Database.User, UserInsertRequest, UserUpdateRequest>, IUserService
    {
        Microsoft.Extensions.Logging.ILogger<UserService> _logger;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly IConnectionFactory _rabbitMqConnectionFactory;

        public UserService(Ib200033Context context, IMapper mapper, Microsoft.Extensions.Logging.ILogger<UserService> logger, IHttpContextAccessor httpContextAccessor, IConnectionFactory rabbitMqConnectionFactory) : base(context, mapper)
        {
            _logger = logger;
            _httpContextAccessor = httpContextAccessor;
            _rabbitMqConnectionFactory = rabbitMqConnectionFactory;
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

            if (!string.IsNullOrWhiteSpace(searchObject?.RoleName))
            {
                query = query.Where(x => x.Roles.Any(r => r.Name == searchObject.RoleName));
            }

            return query;
        }

        public override Models.PagedResult<Models.User> GetPaged(UserSearchObject search)
        {
            var query = Context.Users.AsQueryable();

            query = AddFilter(search, query);

            int count = query.Count();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip(search.Page.Value * search.PageSize.Value).Take(search.PageSize.Value);
            }

            if (!string.IsNullOrWhiteSpace(search?.OrderBy))
            {
                query = query.OrderBy(search.OrderBy);
            }

            var entities = query.ToList();

            var models = entities.Select(entity =>
            {
                var model = entity.Adapt<Models.User>();

                if (search?.IsRoleIncluded == true)
                {
                    model.Roles = entity.Roles?.Select(r => r.Adapt<Models.Role>()).ToList();
                }
                else
                {
                    model.Roles = null;
                }

                model.ImageBase64 = entity.Image != null ? Convert.ToBase64String(entity.Image) : null;

                return model;
            }).ToList();

            return new Models.PagedResult<Models.User>
            {
                ResultList = models,
                Count = count
            };
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

        private void PublishRegistrationEvent(Models.User user)
        {
            using var connection = _rabbitMqConnectionFactory.CreateConnection();
            using var channel = connection.CreateModel();

            channel.QueueDeclare(queue: "user-registration",
                                 durable: false,
                                 exclusive: false,
                                 autoDelete: false,
                                 arguments: null);

            var message = new UserRegistrationMessage
            {
                Email = user.Email,
                Name = user.Name
            };

            string serializedMessage = JsonSerializer.Serialize(message);
            var body = Encoding.UTF8.GetBytes(serializedMessage);

            channel.BasicPublish(exchange: "",
                                 routingKey: "user-registration",
                                 basicProperties: null,
                                 body: body);

            _logger.LogInformation("Published registration message to RabbitMQ for user: {Email}", user.Email);
        }

        public override Models.User Insert(UserInsertRequest request)
        {
            var user = base.Insert(request);

            PublishRegistrationEvent(user);

            return user;
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
            else
            {
                entity.Image = null;
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

        public List<string> GetCurrentUserRoles()
        {
            var currentUserId = GetCurrentUserId();
            var user = Context.Users.Include(u => u.Roles).FirstOrDefault(u => u.Id == currentUserId);

            return user?.Roles?.Select(r => r.Name).ToList() ?? new List<string>();
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

        public override void Delete(int id)
        {
            var user = Context.Set<Database.User>().Include(u => u.Reservations).FirstOrDefault(u => u.Id == id);

            if (user == null)
            {
                throw new Exception("User not found");
            }

            foreach (var reservation in user.Reservations.ToList())
            {
                Context.Set<Database.Reservation>().Remove(reservation);
            }

            Context.Set<Database.User>().Remove(user);
            Context.SaveChanges();
        }

    }
}
