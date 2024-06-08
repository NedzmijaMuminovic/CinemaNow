FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 7102
ENV ASPNETCORE_URLS=http://+:7102

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY . .

FROM build AS publish
RUN dotnet publish "CinemaNow.API/CinemaNow.API.csproj" -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .

ENTRYPOINT ["dotnet", "CinemaNow.API.dll"]