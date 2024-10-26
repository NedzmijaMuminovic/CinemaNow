FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 5200

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["CinemaNow.EmailService/CinemaNow.EmailService.csproj", "CinemaNow.EmailService/"]
COPY ["CinemaNow.Model/CinemaNow.Models.csproj", "CinemaNow.Model/"]
COPY ["CinemaNow.Services/CinemaNow.Services.csproj", "CinemaNow.Services/"]
RUN dotnet restore "CinemaNow.EmailService/CinemaNow.EmailService.csproj"
COPY . .
RUN dotnet build "CinemaNow.EmailService/CinemaNow.EmailService.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "CinemaNow.EmailService/CinemaNow.EmailService.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "CinemaNow.EmailService.dll"]