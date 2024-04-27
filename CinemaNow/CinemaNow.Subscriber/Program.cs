// See https://aka.ms/new-console-template for more information

using CinemaNow.Models.Messages;
using EasyNetQ;

Console.WriteLine("Hello, World!");

var bus = RabbitHutch.CreateBus("host=localhost");
await bus.PubSub.SubscribeAsync<MovieActivated>("console_printer", msg =>
{
    Console.WriteLine($"Movie activated: {msg.Movie.Title}");
});

await bus.PubSub.SubscribeAsync<MovieActivated>("console_printer", msg =>
{
    Console.WriteLine($"Movie activated 2: {msg.Movie.Title}");
});

await bus.PubSub.SubscribeAsync<MovieActivated>("mail_sender", msg =>
{
    Console.WriteLine($"Sending email for: {msg.Movie.Title}");
    //to do: send email
});

Console.WriteLine("Listening for messages, press <return> key to close...");
Console.ReadLine();