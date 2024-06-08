using CinemaNow.API;
using CinemaNow.API.Filters;
using CinemaNow.Services;
using CinemaNow.Services.Database;
using CinemaNow.Services.ScreeningStateMachine;
using Mapster;
using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddTransient<IMovieService, MovieService>();
builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<IGenreService, GenreService>();
builder.Services.AddTransient<IRoleService, RoleService>();
builder.Services.AddTransient<IActorService, ActorService>();
builder.Services.AddTransient<IScreeningService, ScreeningService>();
builder.Services.AddTransient<ISeatService, SeatService>();

builder.Services.AddTransient<BaseScreeningState>();
builder.Services.AddTransient<InitialScreeningState>();
builder.Services.AddTransient<DraftScreeningState>();
builder.Services.AddTransient<ActiveScreeningState>();
builder.Services.AddTransient<HiddenScreeningState>();

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
    var dataContext = scope.ServiceProvider.GetRequiredService<Ib200033Context>();
    //dataContext.Database.EnsureCreated();

    dataContext.Database.Migrate();
}

app.Run();