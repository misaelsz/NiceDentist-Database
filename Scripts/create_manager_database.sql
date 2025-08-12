-- NiceDentist Manager Database Creation Script
-- This script creates the database and tables for the management system

-- Create database if it doesn't exist
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'NiceDentistManagerDb')
BEGIN
    CREATE DATABASE NiceDentistManagerDb;
    PRINT 'Database NiceDentistManagerDb created successfully.';
END
ELSE
BEGIN
    PRINT 'Database NiceDentistManagerDb already exists.';
END
GO

USE NiceDentistManagerDb;
GO

-- Create Users table (shared between customers and dentists)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Users' AND xtype='U')
BEGIN
    CREATE TABLE Users (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Username NVARCHAR(100) NOT NULL UNIQUE,
        PasswordHash NVARCHAR(500) NOT NULL,
        Email NVARCHAR(255) NOT NULL UNIQUE,
        Role NVARCHAR(50) NOT NULL CHECK (Role IN ('Admin', 'Manager', 'Dentist', 'Customer')),
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        IsActive BIT NOT NULL DEFAULT 1
    );
    PRINT 'Table Users created successfully.';
END
ELSE
BEGIN
    PRINT 'Table Users already exists.';
END
GO

-- Create Customers table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Customers' AND xtype='U')
BEGIN
    CREATE TABLE Customers (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL,
        FirstName NVARCHAR(100) NOT NULL,
        LastName NVARCHAR(100) NOT NULL,
        Phone NVARCHAR(20),
        Address NVARCHAR(500),
        DateOfBirth DATE,
        EmergencyContact NVARCHAR(100),
        EmergencyPhone NVARCHAR(20),
        MedicalNotes NVARCHAR(MAX),
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        IsActive BIT NOT NULL DEFAULT 1,
        
        CONSTRAINT FK_Customers_Users FOREIGN KEY (UserId) REFERENCES Users(Id)
    );
    PRINT 'Table Customers created successfully.';
END
ELSE
BEGIN
    PRINT 'Table Customers already exists.';
END
GO

-- Create Dentists table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Dentists' AND xtype='U')
BEGIN
    CREATE TABLE Dentists (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL,
        FirstName NVARCHAR(100) NOT NULL,
        LastName NVARCHAR(100) NOT NULL,
        LicenseNumber NVARCHAR(50) NOT NULL UNIQUE,
        Specialization NVARCHAR(200),
        Phone NVARCHAR(20),
        HireDate DATE NOT NULL,
        Salary DECIMAL(10,2),
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        IsActive BIT NOT NULL DEFAULT 1,
        
        CONSTRAINT FK_Dentists_Users FOREIGN KEY (UserId) REFERENCES Users(Id)
    );
    PRINT 'Table Dentists created successfully.';
END
ELSE
BEGIN
    PRINT 'Table Dentists already exists.';
END
GO

-- Create Schedules table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Schedules' AND xtype='U')
BEGIN
    CREATE TABLE Schedules (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        CustomerId INT NOT NULL,
        DentistId INT NOT NULL,
        AppointmentDate DATETIME2 NOT NULL,
        Duration INT NOT NULL DEFAULT 60, -- Duration in minutes
        Treatment NVARCHAR(300),
        Notes NVARCHAR(MAX),
        Status NVARCHAR(50) NOT NULL DEFAULT 'Scheduled' CHECK (Status IN ('Scheduled', 'Confirmed', 'InProgress', 'Completed', 'Cancelled', 'NoShow')),
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        
        CONSTRAINT FK_Schedules_Customers FOREIGN KEY (CustomerId) REFERENCES Customers(Id),
        CONSTRAINT FK_Schedules_Dentists FOREIGN KEY (DentistId) REFERENCES Dentists(Id)
    );
    PRINT 'Table Schedules created successfully.';
END
ELSE
BEGIN
    PRINT 'Table Schedules already exists.';
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

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_Customers_UserId')
BEGIN
    CREATE INDEX IX_Customers_UserId ON Customers(UserId);
    PRINT 'Index IX_Customers_UserId created successfully.';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_Dentists_UserId')
BEGIN
    CREATE INDEX IX_Dentists_UserId ON Dentists(UserId);
    PRINT 'Index IX_Dentists_UserId created successfully.';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_Schedules_CustomerId')
BEGIN
    CREATE INDEX IX_Schedules_CustomerId ON Schedules(CustomerId);
    PRINT 'Index IX_Schedules_CustomerId created successfully.';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_Schedules_DentistId')
BEGIN
    CREATE INDEX IX_Schedules_DentistId ON Schedules(DentistId);
    PRINT 'Index IX_Schedules_DentistId created successfully.';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_Schedules_AppointmentDate')
BEGIN
    CREATE INDEX IX_Schedules_AppointmentDate ON Schedules(AppointmentDate);
    PRINT 'Index IX_Schedules_AppointmentDate created successfully.';
END

GO

-- Insert seed data for testing
IF NOT EXISTS (SELECT * FROM Users WHERE Username = 'admin')
BEGIN
    INSERT INTO Users (Username, PasswordHash, Email, Role) 
    VALUES ('admin', '$2a$11$5jJ5j5j5j5j5j5j5j5j5j.abcdefghijklmnopqrstuvwxyz123456789', 'admin@nicedentist.com', 'Admin');
    PRINT 'Admin user seeded successfully.';
END

IF NOT EXISTS (SELECT * FROM Users WHERE Username = 'manager')
BEGIN
    INSERT INTO Users (Username, PasswordHash, Email, Role) 
    VALUES ('manager', '$2a$11$5jJ5j5j5j5j5j5j5j5j5j.abcdefghijklmnopqrstuvwxyz123456789', 'manager@nicedentist.com', 'Manager');
    PRINT 'Manager user seeded successfully.';
END

PRINT 'NiceDentist Manager Database setup completed successfully!';
