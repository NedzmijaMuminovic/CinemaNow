// See https://aka.ms/new-console-template for more information

using CinemaNow.Models.Messages;
using EasyNetQ;

Console.WriteLine("Hello, World!");

var bus = RabbitHutch.CreateBus("host=localhost");
await bus.PubSub.SubscribeAsync<ScreeningActivated>("console_printer", msg =>
{
    Console.WriteLine($"Screening activated: {msg.Screening.Movie.Title}");
});

await bus.PubSub.SubscribeAsync<ScreeningActivated>("console_printer", msg =>
{
    Console.WriteLine($"Screening activated 2: {msg.Screening.Movie.Title}");
});

await bus.PubSub.SubscribeAsync<ScreeningActivated>("mail_sender", msg =>
{
    Console.WriteLine($"Sending email for: {msg.Screening.Movie.Title}");
    //to do: send email
});

Console.WriteLine("Listening for messages, press <return> key to close...");
Console.ReadLine();