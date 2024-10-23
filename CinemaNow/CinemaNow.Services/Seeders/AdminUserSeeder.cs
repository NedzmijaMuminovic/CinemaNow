using Microsoft.Extensions.Configuration;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using CinemaNow.Services.Database;

namespace CinemaNow.Services.Seeders
{
    public class AdminUserSeeder : IAdminUserSeeder
    {
        private readonly Ib200033Context _context;

        public AdminUserSeeder(
            Ib200033Context context)
        {
            _context = context;
        }

        public async Task SeedAdminUsers()
        {
            if (!_context.Users.Any(u => u.Email == "admin@mail.com"))
            {
                var adminUser = new User
                {
                    Username = "desktop",
                    Email = "admin@mail.com",
                    Name = "Admin",
                    Surname = "Admin"
                };

                var password = "test";
                var salt = UserService.GenerateSalt();
                var hashedPassword = UserService.GenerateHash(salt, password);

                adminUser.PasswordSalt = salt;
                adminUser.PasswordHash = hashedPassword;

                _context.Users.Add(adminUser);
                await _context.SaveChangesAsync();

                await _context.Database.ExecuteSqlInterpolatedAsync(
                    $"INSERT INTO UserRole (UserID, RoleID) VALUES ({adminUser.Id}, 2)");
            }

            if (!_context.Users.Any(u => u.Email == "user@mail.com"))
            {
                var regularUser = new User
                {
                    Username = "mobile",
                    Email = "user@mail.com",
                    Name = "User",
                    Surname = "User"
                };

                var password = "test";
                var salt = UserService.GenerateSalt();
                var hashedPassword = UserService.GenerateHash(salt, password);

                regularUser.PasswordSalt = salt;
                regularUser.PasswordHash = hashedPassword;

                _context.Users.Add(regularUser);
                await _context.SaveChangesAsync();

                await _context.Database.ExecuteSqlInterpolatedAsync(
                    $"INSERT INTO UserRole (UserID, RoleID) VALUES ({regularUser.Id}, 1)");
            }

            await _context.SaveChangesAsync();
        }


    }
}