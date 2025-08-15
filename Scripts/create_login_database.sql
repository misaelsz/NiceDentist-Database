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
        Role NVARCHAR(50) NOT NULL CHECK (Role IN ('Admin', 'Manager', 'Dentist', 'Customer')),
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        IsActive BIT NOT NULL DEFAULT 1
    );
    PRINT 'Users table created successfully.';
END
GO

-- Create indexes for better performance
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_Users_Email')
BEGIN
    CREATE INDEX IX_Users_Email ON Users(Email);
    PRINT 'Index IX_Users_Email created successfully.';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_Users_Username')
BEGIN
    CREATE INDEX IX_Users_Username ON Users(Username);
    PRINT 'Index IX_Users_Username created successfully.';
END
GO

-- Insert seed data for testing
IF NOT EXISTS (SELECT * FROM Users WHERE Username = 'admin')
BEGIN
    INSERT INTO Users (Username, PasswordHash, Email, Role) 
    VALUES ('admin', '$2a$11$kOa.pQooDLK/A1.ymOJtPujdGQvPdjMMGXDrXlNHly8K65KXPuUYS', 'admin@nicedentist.com', 'Admin');
    PRINT 'Admin user seeded successfully.';
END

IF NOT EXISTS (SELECT * FROM Users WHERE Username = 'manager')
BEGIN
    INSERT INTO Users (Username, PasswordHash, Email, Role) 
    VALUES ('manager', '$2a$11$kOa.pQooDLK/A1.ymOJtPujdGQvPdjMMGXDrXlNHly8K65KXPuUYS', 'manager@nicedentist.com', 'Manager');
    PRINT 'Manager user seeded successfully.';
END

IF NOT EXISTS (SELECT * FROM Users WHERE Username = 'dentist1')
BEGIN
    INSERT INTO Users (Username, PasswordHash, Email, Role) 
    VALUES ('dentist1', '$2a$11$kOa.pQooDLK/A1.ymOJtPujdGQvPdjMMGXDrXlNHly8K65KXPuUYS', 'dentist1@nicedentist.com', 'Dentist');
    PRINT 'Dentist user seeded successfully.';
END

IF NOT EXISTS (SELECT * FROM Users WHERE Username = 'customer1')
BEGIN
    INSERT INTO Users (Username, PasswordHash, Email, Role) 
    VALUES ('customer1', '$2a$11$kOa.pQooDLK/A1.ymOJtPujdGQvPdjMMGXDrXlNHly8K65KXPuUYS', 'customer1@nicedentist.com', 'Customer');
    PRINT 'Customer user seeded successfully.';
END

PRINT 'NiceDentist Auth Database setup completed successfully!';