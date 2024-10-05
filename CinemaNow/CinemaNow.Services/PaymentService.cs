using CinemaNow.Models.Requests;
using CinemaNow.Models.SearchObjects;
using CinemaNow.Services.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Stripe;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CinemaNow.Services
{
    public class PaymentService
    {
        private readonly string _secretKey;
        private readonly Ib200033Context _context;

        public PaymentService(IConfiguration configuration, Ib200033Context context)
        {
            _secretKey = configuration["Stripe:SecretKey"];
            StripeConfiguration.ApiKey = _secretKey;
            _context = context;
        }

        public Payment ProcessStripePayment(string stripePaymentToken, decimal amount)
        {
            var options = new ChargeCreateOptions
            {
                Amount = (long)(amount * 100),
                Currency = "usd",
                Description = "Cinema ticket purchase",
                Source = stripePaymentToken,
            };

            var service = new ChargeService();
            Charge charge = service.Create(options);

            var payment = new Payment
            {
                Provider = "Stripe",
                TransactionId = charge.Id,
                Amount = amount,
                DateTime = DateTime.Now
            };

            _context.Payments.Add(payment);
            _context.SaveChanges();

            return payment;
        }
    }

}
