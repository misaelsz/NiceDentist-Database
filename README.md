# Database stack

This folder contains the SQL Server stack and initialization scripts for the project.

## Contents
- docker-compose.yml – SQL Server service and one-shot initializer (db-init)
- db.env – environment variables for the DB (port, SA password, DB name)
- Scripts/ – SQL scripts (create_login_database.sql)

## Quick start (Windows PowerShell)

1) Start SQL Server

```powershell
cd NiceDentist-Database
docker compose --env-file db.env up -d sqlserver
```

2) Initialize schema (create DB and tables)

```powershell
docker compose --env-file db.env --profile init up --build db-init
```

3) Verify

```powershell
docker compose exec sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$($env:SA_PASSWORD)" -Q "SELECT name FROM sys.databases"
```

If the above env interpolation doesn’t resolve in your shell, replace with the literal password from `db.env`.

## Connection info
- Host (from your Windows host): `localhost,1433` (use the port in `db.env` if you changed it)
- Auth: SQL Server Authentication
- User: `sa`
- Password: value from `db.env` (SA_PASSWORD)
- Default DB: `NiceDentistAuthDb` (after init)

Example connection string from host apps:

```
Server=localhost,1433;Database=NiceDentistAuthDb;User Id=sa;Password=Your_strong_password123!;TrustServerCertificate=True;
```

When connecting from another Docker stack/container on the same machine (separate compose projects), point to the host’s published port via:

```
Server=host.docker.internal,1433;Database=NiceDentistAuthDb;User Id=sa;Password=Your_strong_password123!;TrustServerCertificate=True;
```

## Troubleshooting
- Error 4060 “Cannot open database … requested by the login”: run the initializer (step 2) or create the DB with `Scripts/create_login_database.sql`.
- Port in use: change `SQL_PORT` in `db.env` and re-run.
- Reset DB: `docker compose down -v` in this folder to remove the data volume, then start again.
