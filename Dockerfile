FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine AS build
WORKDIR /src

COPY ./Latte-Cafe-API/Latte-Cafe-API.csproj ./Latte-Cafe-API/
COPY ./DataAccess/DataAccess.csproj ./DataAccess/
COPY ./Services/Services.csproj ./Services/

RUN dotnet restore ./Latte-Cafe-API/Latte-Cafe-API.csproj

COPY . ./
WORKDIR /src
RUN dotnet build ./Latte-Cafe-API/Latte-Cafe-API.csproj -c Prod -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish ./Latte-Cafe-API/Latte-Cafe-API.csproj -c Prod -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Api.dll"]
