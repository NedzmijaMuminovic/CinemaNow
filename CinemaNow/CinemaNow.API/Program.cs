using CinemaNow.API;
using CinemaNow.API.Filters;
using CinemaNow.Models.SearchObjects;
using CinemaNow.Services;
using CinemaNow.Services.Database;
using CinemaNow.Services.MachineLearning;
using CinemaNow.Services.ScreeningStateMachine;
using CinemaNow.Services.Seeders;
using DotNetEnv;
using Mapster;
using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using RabbitMQ.Client;

Env.Load(@"../.env");

var builder = WebApplication.CreateBuilder(args);

var stripeSecretKey = Environment.GetEnvironmentVariable("STRIPE_SECRET_KEY");

builder.Services.AddSingleton<IConnectionFactory>(sp =>
{
    var hostname = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
    return new ConnectionFactory()
    {
        HostName = hostname,
        RequestedHeartbeat = TimeSpan.FromSeconds(60),
        AutomaticRecoveryEnabled = true
    };
});

// Add services to the container.
builder.Services.AddTransient<IMovieService, MovieService>();
builder.Services.AddTransient<IMovieRecommenderService, MovieRecommenderService>();
builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<IGenreService, GenreService>();
builder.Services.AddTransient<IRoleService, RoleService>();
builder.Services.AddTransient<IActorService, ActorService>();
builder.Services.AddTransient<IScreeningService, ScreeningService>();
builder.Services.AddTransient<ISeatService, SeatService>();
builder.Services.AddTransient<IHallService, HallService>();
builder.Services.AddTransient<IViewModeService, ViewModeService>();
builder.Services.AddTransient<IRatingService, RatingService>();

builder.Services.AddTransient(sp => new PaymentService(stripeSecretKey, sp.GetRequiredService<Ib200033Context>()));

builder.Services.AddTransient<IReservationService, ReservationService>();
builder.Services.AddTransient<IReportService, ReportService>();

builder.Services.AddTransient<BaseScreeningState>();
builder.Services.AddTransient<InitialScreeningState>();
builder.Services.AddTransient<DraftScreeningState>();
builder.Services.AddTransient<ActiveScreeningState>();
builder.Services.AddTransient<HiddenScreeningState>();

builder.Services.AddTransient<IAdminUserSeeder, AdminUserSeeder>();
builder.Services.AddTransient<IMovieActorImageSeeder>(sp =>
{
    var env = sp.GetRequiredService<IWebHostEnvironment>();
    var imageFolderPath = Path.Combine(env.ContentRootPath, "Images");
    var context = sp.GetRequiredService<Ib200033Context>();
    return new MovieActorImageSeeder(context, imageFolderPath);
});


builder.Services.AddHttpContextAccessor();

builder.Services.AddControllers( x =>
{
    x.Filters.Add<ExceptionFilter>();
});
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
if (builder.Environment.IsDevelopment())
{
    builder.Services.AddSwaggerGen(c =>
    {
        c.AddSecurityDefinition("basicAuth", new Microsoft.OpenApi.Models.OpenApiSecurityScheme()
        {
            Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
            Scheme = "basic"
        });
    
        c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement()
        {
            {
                new OpenApiSecurityScheme
                {
                    Reference = new OpenApiReference{Type = ReferenceType.SecurityScheme, Id = "basicAuth"}
                },
                new string[]{}
            }
        });
    });
}

var connectionString = builder.Configuration.GetConnectionString("CinemaNowConnection");
builder.Services.AddDbContext<Ib200033Context>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddMapster();
builder.Services.AddAuthentication("BasicAuthentication")
    .AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
if (Environment.GetEnvironmentVariable("USE_HTTPS") == "true")
{
    app.UseHttpsRedirection();
}

app.UseAuthorization();

app.MapControllers();

using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var context = services.GetRequiredService<Ib200033Context>();
        context.Database.Migrate();

        var adminSeeder = services.GetRequiredService<IAdminUserSeeder>();
        await adminSeeder.SeedAdminUsers();

        var imageSeeder = services.GetRequiredService<IMovieActorImageSeeder>();
        await imageSeeder.SeedMovieActorImages();
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "An error occurred while migrating or seeding the database.");
        throw;
    }
}

app.Run();