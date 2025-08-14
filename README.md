# NiceDentist Database Infrastructure

This folder contains the SQL Server setup for both Authentication API and Manager API systems.

## 🚀 Quick Setup

**One-command setup:**
```powershell
cd NiceDentist-Database
docker compose up -d
```

This will automatically:
- Start SQL Server with health checks
- Wait for SQL Server to be ready
- Create both databases (Auth and Manager)
- Run all initialization scripts
- Verify the setup

**Alternative batch script:**
```powershell
.\setup-database.bat
```

## ✅ Verify Setup
```powershell
# Check databases exist
docker exec nicedentist-database-sqlserver-1 /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "Your_strong_password123!" -C -Q "SELECT name FROM sys.databases WHERE name IN ('NiceDentistAuthDb', 'NiceDentistManagerDb')"

# Check Manager tables
docker exec nicedentist-database-sqlserver-1 /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "Your_strong_password123!" -C -d NiceDentistManagerDb -Q "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'"

# Check logs if needed
docker compose logs db-init
```

## Connection Strings

**Auth Database:**
```
Server=localhost,1433;Database=NiceDentistAuthDb;User Id=sa;Password=Your_strong_password123!;TrustServerCertificate=True;
```

**Manager Database:**
```
Server=localhost,1433;Database=NiceDentistManagerDb;User Id=sa;Password=Your_strong_password123!;TrustServerCertificate=True;
```

**From other Docker containers:**
```
Server=host.docker.internal,1433;Database=NiceDentistAuthDb;User Id=sa;Password=Your_strong_password123!;TrustServerCertificate=True;
Server=host.docker.internal,1433;Database=NiceDentistManagerDb;User Id=sa;Password=Your_strong_password123!;TrustServerCertificate=True;
```

## Database Schemas

### Auth Database (NiceDentistAuthDb)
- **Users** - Authentication table

### Manager Database (NiceDentistManagerDb)
- **Users** - Shared authentication (Admin, Manager, Dentist, Customer roles)
- **Customers** - Patient records (linked to Users via UserId)
- **Dentists** - Dentist profiles (linked to Users via UserId)
- **Schedules** - Appointments (links Customers and Dentists)

## Management Commands
```powershell
# Stop
docker compose down

# Reset (removes all data)
docker compose down -v

# View logs
docker compose logs
docker compose logs db-init
```

## Files
- `docker-compose.yml` - SQL Server with automatic database initialization
- `Scripts/create_login_database.sql` - Auth database schema
- `Scripts/create_manager_database.sql` - Manager database schema with all tables
- `setup-database.bat` - Automated setup script

## Seed Data
The Manager database includes:
- Admin user: `admin@nicedentist.com` (Role: Admin)
- Manager user: `manager@nicedentist.com` (Role: Manager)

Both users have placeholder password hashes that should be updated in production.

## Troubleshooting
- **Initialization failed**: Check logs with `docker compose logs db-init`
- **Port in use**: Change port in docker-compose.yml and restart
- **Reset everything**: `docker compose down -v` to remove data volume, then `docker compose up -d`
