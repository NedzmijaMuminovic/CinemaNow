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
        private readonly Ib200033Context _context;

        public PaymentService(string stripeSecretKey, Ib200033Context context)
        {
            StripeConfiguration.ApiKey = stripeSecretKey;
            _context = context;
        }

        public Payment ProcessStripePayment(string paymentIntentId, decimal amount)
        {
            var service = new PaymentIntentService();
            var paymentIntent = service.Get(paymentIntentId);

            //if (paymentIntent.Status != "succeeded")
            //{
            //    throw new InvalidOperationException("Payment not successful.");
            //}

            var payment = new Payment
            {
                Provider = "Stripe",
                TransactionId = paymentIntent.Id,
                Amount = amount,
                DateTime = DateTime.Now
            };

            _context.Payments.Add(payment);
            _context.SaveChanges();

            return payment;
        }

        public async Task<PaymentIntent> CreatePaymentIntentAsync(int amount)
        {
            var options = new PaymentIntentCreateOptions
            {
                Amount = amount,
                Currency = "usd",
                PaymentMethodTypes = new List<string> { "card" },
            };
            var service = new PaymentIntentService();
            return await service.CreateAsync(options);
        }
    }

}
