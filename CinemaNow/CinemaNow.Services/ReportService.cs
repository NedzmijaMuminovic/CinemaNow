﻿using CinemaNow.Models;
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
using CinemaNow.Models.Reports;

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

        public async Task<List<MovieReservationSeatCount>> GetTop5WatchedMoviesAsync()
        {
            var top5Movies = await _context.Reservations
                .SelectMany(r => r.ReservationSeats)
                .GroupBy(rs => rs.Reservation.Screening.MovieId)
                .Select(g => new MovieReservationSeatCount
                {
                    MovieId = g.Key ?? 0,
                    MovieTitle = g.FirstOrDefault().Reservation.Screening.Movie.Title,
                    ReservationSeatCount = g.Count()
                })
                .OrderByDescending(m => m.ReservationSeatCount)
                .Take(5)
                .ToListAsync();

            return top5Movies;
        }

        public async Task<List<MovieRevenue>> GetRevenueByMovieAsync()
        {
            var movieRevenues = await _context.Reservations
                .GroupBy(r => r.Screening.MovieId)
                .Select(g => new MovieRevenue
                {
                    MovieId = g.Key ?? 0,
                    MovieTitle = g.FirstOrDefault().Screening.Movie.Title,
                    TotalRevenue = g.Sum(r => r.TotalPrice) ?? 0
                })
                .OrderByDescending(m => m.TotalRevenue)
                .Take(5)
                .ToListAsync();

            return movieRevenues;
        }

        public async Task<List<TopCustomer>> GetTop5CustomersAsync()
        {
            var top5Customers = await _context.Reservations
                .GroupBy(r => r.UserId)
                .Select(g => new TopCustomer
                {
                    UserId = g.Key,
                    Name = g.FirstOrDefault().User.Name,
                    Surname = g.FirstOrDefault().User.Surname,
                    TotalSpent = g.Sum(r => r.TotalPrice) ?? 0
                })
                .OrderByDescending(c => c.TotalSpent)
                .Take(5)
                .ToListAsync();

            return top5Customers;
        }

    }
}
