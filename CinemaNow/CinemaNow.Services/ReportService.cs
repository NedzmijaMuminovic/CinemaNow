using CinemaNow.Models;
using CinemaNow.Models.SearchObjects;
using CinemaNow.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Linq.Dynamic.Core;
using CinemaNow.Models.Requests;
using Microsoft.EntityFrameworkCore;

namespace CinemaNow.Services
{
    public class ReportService : IReportService
    {
        private readonly Ib200033Context _context;

        public ReportService(Ib200033Context context)
        {
            _context = context;
        }

        public async Task<int> GetUserCountAsync()
        {
            var userCount = await _context.Users
                .Where(u => u.Roles.Any(r => r.Name == "User"))
                .CountAsync();

            return userCount;
        }

        public async Task<decimal> GetTotalCinemaIncomeAsync()
        {
            var totalIncome = await _context.Reservations
                .Where(r => r.PaymentType == "Cash" || r.PaymentType == "Stripe")
                .SumAsync(r => r.TotalPrice);

            return totalIncome ?? 0;
        }
    }
}
