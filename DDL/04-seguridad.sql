USE CoworkingReservas;
GO

IF OBJECT_ID(N'dbo.Perfiles', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Perfiles
    (
        PerfilId INT IDENTITY(1, 1) NOT NULL,
        Nombre NVARCHAR(50) NOT NULL,
        CONSTRAINT PK_Perfiles PRIMARY KEY (PerfilId),
        CONSTRAINT UQ_Perfiles_Nombre UNIQUE (Nombre)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Perfiles WHERE Nombre = N'Administrador')
    INSERT INTO dbo.Perfiles (Nombre) VALUES (N'Administrador');
IF NOT EXISTS (SELECT 1 FROM dbo.Perfiles WHERE Nombre = N'Cliente')
    INSERT INTO dbo.Perfiles (Nombre) VALUES (N'Cliente');
GO

IF COL_LENGTH(N'dbo.Usuarios', N'PasswordHash') IS NULL
    ALTER TABLE dbo.Usuarios ADD PasswordHash NVARCHAR(255) NULL;
GO

IF COL_LENGTH(N'dbo.Usuarios', N'PerfilId') IS NULL
    ALTER TABLE dbo.Usuarios ADD PerfilId INT NULL;
GO

DECLARE @ClienteId INT;
DECLARE @AdminId INT;
SELECT @ClienteId = PerfilId FROM dbo.Perfiles WHERE Nombre = N'Cliente';
SELECT @AdminId = PerfilId FROM dbo.Perfiles WHERE Nombre = N'Administrador';

UPDATE dbo.Usuarios
SET PerfilId = @ClienteId
WHERE PerfilId IS NULL;

UPDATE dbo.Usuarios
SET PasswordHash = N'$2b$10$ikDVeLD1SV6PKiHT2y43fuYDEysoXlgp21w3ktXIj7TUR/0I6SwnC'
WHERE PasswordHash IS NULL;

UPDATE dbo.Usuarios
SET PasswordHash = N'$2b$10$EklQic5lr.ZOfJKROU4eTuBR5l3F24/zC/p/8VHCuIlxTmDhYiTLu',
    PerfilId = @AdminId
WHERE Email = N'ana@coworking.test';

UPDATE dbo.Usuarios
SET PasswordHash = N'$2b$10$ikDVeLD1SV6PKiHT2y43fuYDEysoXlgp21w3ktXIj7TUR/0I6SwnC',
    PerfilId = @ClienteId
WHERE Email = N'luis@coworking.test';
GO

IF EXISTS (SELECT 1 FROM dbo.Usuarios WHERE PasswordHash IS NULL OR PerfilId IS NULL)
BEGIN
    THROW 50000, 'Hay usuarios sin clave o sin perfil.', 1;
END
GO

ALTER TABLE dbo.Usuarios ALTER COLUMN PasswordHash NVARCHAR(255) NOT NULL;
ALTER TABLE dbo.Usuarios ALTER COLUMN PerfilId INT NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Usuarios_Perfiles')
    ALTER TABLE dbo.Usuarios
    ADD CONSTRAINT FK_Usuarios_Perfiles FOREIGN KEY (PerfilId) REFERENCES dbo.Perfiles (PerfilId);
GO
