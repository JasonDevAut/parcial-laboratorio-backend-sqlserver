IF DB_ID(N'CoworkingReservas') IS NULL
BEGIN
    CREATE DATABASE CoworkingReservas;
END
GO

USE CoworkingReservas;
GO

IF OBJECT_ID(N'dbo.Reservas', N'U') IS NOT NULL DROP TABLE dbo.Reservas;
IF OBJECT_ID(N'dbo.Salas', N'U') IS NOT NULL DROP TABLE dbo.Salas;
IF OBJECT_ID(N'dbo.Usuarios', N'U') IS NOT NULL DROP TABLE dbo.Usuarios;
IF OBJECT_ID(N'dbo.Perfiles', N'U') IS NOT NULL DROP TABLE dbo.Perfiles;
GO

CREATE TABLE dbo.Perfiles
(
    PerfilId INT IDENTITY(1, 1) NOT NULL,
    Nombre NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_Perfiles PRIMARY KEY (PerfilId),
    CONSTRAINT UQ_Perfiles_Nombre UNIQUE (Nombre)
);
GO

CREATE TABLE dbo.Usuarios
(
    UsuarioId INT IDENTITY(1, 1) NOT NULL,
    Nombre NVARCHAR(100) NOT NULL,
    Apellido NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) NOT NULL,
    Telefono NVARCHAR(30) NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    PerfilId INT NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Usuarios_Activo DEFAULT (1),
    FechaCreacion DATETIME2 NOT NULL CONSTRAINT DF_Usuarios_FechaCreacion DEFAULT (SYSUTCDATETIME()),
    FechaActualizacion DATETIME2 NULL,
    CONSTRAINT PK_Usuarios PRIMARY KEY (UsuarioId),
    CONSTRAINT UQ_Usuarios_Email UNIQUE (Email),
    CONSTRAINT FK_Usuarios_Perfiles FOREIGN KEY (PerfilId) REFERENCES dbo.Perfiles (PerfilId)
);
GO

CREATE TABLE dbo.Salas
(
    SalaId INT IDENTITY(1, 1) NOT NULL,
    Nombre NVARCHAR(120) NOT NULL,
    Capacidad INT NOT NULL,
    Ubicacion NVARCHAR(150) NOT NULL,
    Descripcion NVARCHAR(500) NULL,
    Activa BIT NOT NULL CONSTRAINT DF_Salas_Activa DEFAULT (1),
    FechaCreacion DATETIME2 NOT NULL CONSTRAINT DF_Salas_FechaCreacion DEFAULT (SYSUTCDATETIME()),
    FechaActualizacion DATETIME2 NULL,
    CONSTRAINT PK_Salas PRIMARY KEY (SalaId),
    CONSTRAINT CK_Salas_Capacidad CHECK (Capacidad > 0)
);
GO

CREATE TABLE dbo.Reservas
(
    ReservaId INT IDENTITY(1, 1) NOT NULL,
    UsuarioId INT NOT NULL,
    SalaId INT NOT NULL,
    FechaInicio DATETIME2 NOT NULL,
    FechaFin DATETIME2 NOT NULL,
    Estado NVARCHAR(20) NOT NULL CONSTRAINT DF_Reservas_Estado DEFAULT (N'CONFIRMADA'),
    FechaCreacion DATETIME2 NOT NULL CONSTRAINT DF_Reservas_FechaCreacion DEFAULT (SYSUTCDATETIME()),
    FechaActualizacion DATETIME2 NULL,
    CONSTRAINT PK_Reservas PRIMARY KEY (ReservaId),
    CONSTRAINT FK_Reservas_Usuarios FOREIGN KEY (UsuarioId) REFERENCES dbo.Usuarios (UsuarioId),
    CONSTRAINT FK_Reservas_Salas FOREIGN KEY (SalaId) REFERENCES dbo.Salas (SalaId),
    CONSTRAINT CK_Reservas_Estado CHECK (Estado IN (N'CONFIRMADA', N'CANCELADA')),
    CONSTRAINT CK_Reservas_Intervalo CHECK (FechaFin > FechaInicio)
);
GO
