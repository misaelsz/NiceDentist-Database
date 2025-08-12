-- Create database for login system (idempotent)
IF DB_ID('NiceDentistAuthDb') IS NULL
BEGIN
    CREATE DATABASE NiceDentistAuthDb;
END
GO

USE NiceDentistAuthDb;
GO

-- User Table for Login (idempotent)
IF OBJECT_ID('dbo.Users', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Users (
        Id INT PRIMARY KEY IDENTITY(1,1),
        Username NVARCHAR(100) NOT NULL UNIQUE,
        PasswordHash NVARCHAR(256) NOT NULL,
        Email NVARCHAR(256) NOT NULL UNIQUE,
        Role NVARCHAR(50) NOT NULL,
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        IsActive BIT NOT NULL DEFAULT 1
    );
END