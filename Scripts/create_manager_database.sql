-- NiceDentist Manager Database Creation Script
-- This script creates the database and tables for the management system
-- Users table is in the Auth database (NiceDentistAuthDb)

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

-- Create Customers table (references Users in Auth DB)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Customers' AND xtype='U')
BEGIN
    CREATE TABLE Customers (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NULL, -- References NiceDentistAuthDb.dbo.Users.Id - will be set after account activation
        Name NVARCHAR(200) NOT NULL,
        Email NVARCHAR(255) NOT NULL UNIQUE,
        Phone NVARCHAR(20) NOT NULL,
        DateOfBirth DATE,
        Address NVARCHAR(500),
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        IsActive BIT NOT NULL DEFAULT 1
    );
    PRINT 'Table Customers created successfully.';
END
ELSE
BEGIN
    PRINT 'Table Customers already exists.';
END
GO

-- Create Dentists table (references Users in Auth DB)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Dentists' AND xtype='U')
BEGIN
    CREATE TABLE Dentists (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NULL, -- References NiceDentistAuthDb.dbo.Users.Id - will be set after account activation
        Name NVARCHAR(200) NOT NULL,
        Email NVARCHAR(255) NOT NULL UNIQUE,
        Phone NVARCHAR(20) NOT NULL,
        LicenseNumber NVARCHAR(50) NOT NULL UNIQUE,
        Specialization NVARCHAR(200),
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        IsActive BIT NOT NULL DEFAULT 1
    );
    PRINT 'Table Dentists created successfully.';
END
ELSE
BEGIN
    PRINT 'Table Dentists already exists.';
END
GO

-- Create Appointments table (renamed from Schedules for clarity)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Appointments' AND xtype='U')
BEGIN
    CREATE TABLE Appointments (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        CustomerId INT NOT NULL,
        DentistId INT NOT NULL,
        AppointmentDateTime DATETIME2 NOT NULL,
        ProcedureType NVARCHAR(300) NOT NULL,
        Notes NVARCHAR(MAX),
        Status NVARCHAR(50) NOT NULL DEFAULT 'Scheduled' CHECK (Status IN ('Scheduled', 'Completed', 'Cancelled', 'CancellationRequested')),
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        
        CONSTRAINT FK_Appointments_Customers FOREIGN KEY (CustomerId) REFERENCES Customers(Id),
        CONSTRAINT FK_Appointments_Dentists FOREIGN KEY (DentistId) REFERENCES Dentists(Id)
    );
    PRINT 'Table Appointments created successfully.';
END
ELSE
BEGIN
    PRINT 'Table Appointments already exists.';
END
GO

-- Create indexes for better performance
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

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_Appointments_CustomerId')
BEGIN
    CREATE INDEX IX_Appointments_CustomerId ON Appointments(CustomerId);
    PRINT 'Index IX_Appointments_CustomerId created successfully.';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_Appointments_DentistId')
BEGIN
    CREATE INDEX IX_Appointments_DentistId ON Appointments(DentistId);
    PRINT 'Index IX_Appointments_DentistId created successfully.';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_Appointments_DateTime')
BEGIN
    CREATE INDEX IX_Appointments_DateTime ON Appointments(AppointmentDateTime);
    PRINT 'Index IX_Appointments_DateTime created successfully.';
END

GO

-- Insert seed data for Customers (initially without UserId, will be linked via events)
INSERT INTO Customers (Name, Email, Phone, DateOfBirth, Address)
VALUES 
    ('Maria Silva', 'maria.silva@email.com', '(11) 99999-1111', '1985-03-15', 'Rua das Flores, 123, São Paulo'),
    ('João Santos', 'joao.santos@email.com', '(11) 99999-2222', '1990-07-22', 'Av. Paulista, 456, São Paulo'),
    ('Ana Costa', 'ana.costa@email.com', '(11) 99999-3333', '1988-11-08', 'Rua Augusta, 789, São Paulo');

-- Insert seed data for Dentists (initially without UserId, will be linked via events)  
INSERT INTO Dentists (Name, Email, Phone, LicenseNumber, Specialization)
VALUES 
    ('Dr. Carlos Oliveira', 'carlos.oliveira@nicedentist.com', '(11) 99999-4444', 'CRO-SP-12345', 'Ortodontia'),
    ('Dra. Fernanda Lima', 'fernanda.lima@nicedentist.com', '(11) 99999-5555', 'CRO-SP-67890', 'Endodontia'),
    ('Dr. Roberto Dias', 'roberto.dias@nicedentist.com', '(11) 99999-6666', 'CRO-SP-11111', 'Implantologia');

-- Insert seed data for Appointments
INSERT INTO Appointments (CustomerId, DentistId, AppointmentDateTime, ProcedureType, Notes, Status)
VALUES 
    (1, 1, '2024-01-15 09:00:00', 'Consulta inicial + Limpeza', 'Primeira consulta da paciente', 'Scheduled'),
    (1, 1, '2024-01-22 14:00:00', 'Instalação de aparelho ortodôntico', 'Iniciar tratamento ortodôntico', 'Scheduled'),
    (2, 2, '2024-01-16 10:30:00', 'Tratamento de canal', 'Dor no molar superior direito', 'Scheduled'),
    (3, 3, '2024-01-17 15:00:00', 'Avaliação para implante', 'Consulta para implante unitário', 'Scheduled');

GO

PRINT 'NiceDentist Manager Database setup completed successfully!';
PRINT 'Note: Users are managed in NiceDentistAuthDb. Use UserId to reference users.';
