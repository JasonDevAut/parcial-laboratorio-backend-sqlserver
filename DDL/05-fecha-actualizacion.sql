USE CoworkingReservas;
GO

IF COL_LENGTH(N'dbo.Usuarios', N'FechaActualizacion') IS NULL
    ALTER TABLE dbo.Usuarios ADD FechaActualizacion DATETIME2 NULL;
GO

IF COL_LENGTH(N'dbo.Salas', N'FechaActualizacion') IS NULL
    ALTER TABLE dbo.Salas ADD FechaActualizacion DATETIME2 NULL;
GO

IF COL_LENGTH(N'dbo.Reservas', N'FechaActualizacion') IS NULL
    ALTER TABLE dbo.Reservas ADD FechaActualizacion DATETIME2 NULL;
GO
