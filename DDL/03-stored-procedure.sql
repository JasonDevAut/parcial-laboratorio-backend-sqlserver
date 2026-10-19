USE CoworkingReservas;
GO

CREATE OR ALTER PROCEDURE dbo.sp_registrar_reserva
    @UsuarioId INT,
    @SalaId INT,
    @FechaInicio DATETIME2,
    @FechaFin DATETIME2,
    @ReservaId INT OUTPUT,
    @Codigo INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @ReservaId = NULL;
    SET @Codigo = 0;

    IF @FechaInicio IS NULL OR @FechaFin IS NULL OR @FechaFin <= @FechaInicio
    BEGIN
        SET @Codigo = 4;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @UsuarioActivo BIT;
        DECLARE @SalaActiva BIT;

        SELECT @UsuarioActivo = Activo
        FROM dbo.Usuarios WITH (UPDLOCK, HOLDLOCK)
        WHERE UsuarioId = @UsuarioId;

        IF @UsuarioActivo IS NULL
        BEGIN
            SET @Codigo = 1;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF @UsuarioActivo = 0
        BEGIN
            SET @Codigo = 2;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        SELECT @SalaActiva = Activa
        FROM dbo.Salas WITH (UPDLOCK, HOLDLOCK)
        WHERE SalaId = @SalaId;

        IF @SalaActiva IS NULL
        BEGIN
            SET @Codigo = 1;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF @SalaActiva = 0
        BEGIN
            SET @Codigo = 2;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF EXISTS (
            SELECT 1
            FROM dbo.Reservas WITH (UPDLOCK, HOLDLOCK)
            WHERE SalaId = @SalaId
              AND Estado = N'CONFIRMADA'
              AND FechaInicio < @FechaFin
              AND FechaFin > @FechaInicio
        )
        BEGIN
            SET @Codigo = 3;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        INSERT INTO dbo.Reservas (UsuarioId, SalaId, FechaInicio, FechaFin, Estado)
        VALUES (@UsuarioId, @SalaId, @FechaInicio, @FechaFin, N'CONFIRMADA');

        SET @ReservaId = CONVERT(INT, SCOPE_IDENTITY());
        SET @Codigo = 0;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

GO

CREATE OR ALTER PROCEDURE dbo.sp_buscar_usuario_por_email
    @Email NVARCHAR(255),
    @UsuarioId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT UsuarioId
    FROM dbo.Usuarios
    WHERE Email = @Email
      AND (@UsuarioId IS NULL OR UsuarioId <> @UsuarioId);
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_obtener_usuario_por_email
    @Email NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT u.UsuarioId, u.Nombre, u.Apellido, u.Email, u.Telefono, u.Activo, u.PasswordHash, u.FechaActualizacion, p.Nombre AS Perfil
    FROM dbo.Usuarios AS u
    INNER JOIN dbo.Perfiles AS p ON p.PerfilId = u.PerfilId
    WHERE u.Email = @Email;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_insertar_usuario
    @Nombre NVARCHAR(100),
    @Apellido NVARCHAR(100),
    @Email NVARCHAR(255),
    @Telefono NVARCHAR(30) = NULL,
    @PasswordHash NVARCHAR(255),
    @Perfil NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PerfilId INT;
    SELECT @PerfilId = PerfilId FROM dbo.Perfiles WHERE Nombre = @Perfil;
    IF @PerfilId IS NULL RETURN;

    DECLARE @Ids TABLE (UsuarioId INT);

    INSERT INTO dbo.Usuarios (Nombre, Apellido, Email, Telefono, PasswordHash, PerfilId)
    OUTPUT inserted.UsuarioId INTO @Ids (UsuarioId)
    VALUES (@Nombre, @Apellido, @Email, @Telefono, @PasswordHash, @PerfilId);

    SELECT u.UsuarioId, u.Nombre, u.Apellido, u.Email, u.Telefono, u.Activo, u.FechaActualizacion, p.Nombre AS Perfil
    FROM dbo.Usuarios AS u
    INNER JOIN @Ids AS i ON i.UsuarioId = u.UsuarioId
    INNER JOIN dbo.Perfiles AS p ON p.PerfilId = u.PerfilId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_listar_usuarios
AS
BEGIN
    SET NOCOUNT ON;

    SELECT u.UsuarioId, u.Nombre, u.Apellido, u.Email, u.Telefono, u.Activo, u.FechaActualizacion, p.Nombre AS Perfil
    FROM dbo.Usuarios AS u
    INNER JOIN dbo.Perfiles AS p ON p.PerfilId = u.PerfilId
    ORDER BY u.UsuarioId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_obtener_usuario
    @UsuarioId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT u.UsuarioId, u.Nombre, u.Apellido, u.Email, u.Telefono, u.Activo, u.FechaActualizacion, p.Nombre AS Perfil
    FROM dbo.Usuarios AS u
    INNER JOIN dbo.Perfiles AS p ON p.PerfilId = u.PerfilId
    WHERE u.UsuarioId = @UsuarioId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_actualizar_usuario
    @UsuarioId INT,
    @Nombre NVARCHAR(100),
    @Apellido NVARCHAR(100),
    @Email NVARCHAR(255),
    @Telefono NVARCHAR(30) = NULL,
    @PasswordHash NVARCHAR(255) = NULL,
    @Perfil NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PerfilId INT = NULL;
    IF @Perfil IS NOT NULL
    BEGIN
        SELECT @PerfilId = PerfilId FROM dbo.Perfiles WHERE Nombre = @Perfil;
        IF @PerfilId IS NULL RETURN;
    END

    UPDATE dbo.Usuarios
    SET Nombre = @Nombre,
        Apellido = @Apellido,
        Email = @Email,
        Telefono = @Telefono,
        PasswordHash = COALESCE(@PasswordHash, PasswordHash),
        PerfilId = COALESCE(@PerfilId, PerfilId),
        FechaActualizacion = SYSUTCDATETIME()
    WHERE UsuarioId = @UsuarioId;

    SELECT u.UsuarioId, u.Nombre, u.Apellido, u.Email, u.Telefono, u.Activo, u.FechaActualizacion, p.Nombre AS Perfil
    FROM dbo.Usuarios AS u
    INNER JOIN dbo.Perfiles AS p ON p.PerfilId = u.PerfilId
    WHERE u.UsuarioId = @UsuarioId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_desactivar_usuario
    @UsuarioId INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Usuarios
    SET Activo = 0,
        FechaActualizacion = SYSUTCDATETIME()
    WHERE UsuarioId = @UsuarioId;

    SELECT u.UsuarioId, u.Nombre, u.Apellido, u.Email, u.Telefono, u.Activo, u.FechaActualizacion, p.Nombre AS Perfil
    FROM dbo.Usuarios AS u
    INNER JOIN dbo.Perfiles AS p ON p.PerfilId = u.PerfilId
    WHERE u.UsuarioId = @UsuarioId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_insertar_sala
    @Nombre NVARCHAR(120),
    @Capacidad INT,
    @Ubicacion NVARCHAR(150),
    @Descripcion NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Salas (Nombre, Capacidad, Ubicacion, Descripcion)
    OUTPUT inserted.SalaId, inserted.Nombre, inserted.Capacidad, inserted.Ubicacion, inserted.Descripcion, inserted.Activa, inserted.FechaActualizacion
    VALUES (@Nombre, @Capacidad, @Ubicacion, @Descripcion);
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_listar_salas
AS
BEGIN
    SET NOCOUNT ON;

    SELECT SalaId, Nombre, Capacidad, Ubicacion, Descripcion, Activa, FechaActualizacion
    FROM dbo.Salas
    ORDER BY SalaId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_obtener_sala
    @SalaId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT SalaId, Nombre, Capacidad, Ubicacion, Descripcion, Activa, FechaActualizacion
    FROM dbo.Salas
    WHERE SalaId = @SalaId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_actualizar_sala
    @SalaId INT,
    @Nombre NVARCHAR(120),
    @Capacidad INT,
    @Ubicacion NVARCHAR(150),
    @Descripcion NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Salas
    SET Nombre = @Nombre, Capacidad = @Capacidad, Ubicacion = @Ubicacion, Descripcion = @Descripcion,
        FechaActualizacion = SYSUTCDATETIME()
    OUTPUT inserted.SalaId, inserted.Nombre, inserted.Capacidad, inserted.Ubicacion, inserted.Descripcion, inserted.Activa, inserted.FechaActualizacion
    WHERE SalaId = @SalaId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_desactivar_sala
    @SalaId INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Salas
    SET Activa = 0,
        FechaActualizacion = SYSUTCDATETIME()
    OUTPUT inserted.SalaId, inserted.Nombre, inserted.Capacidad, inserted.Ubicacion, inserted.Descripcion, inserted.Activa, inserted.FechaActualizacion
    WHERE SalaId = @SalaId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_listar_reservas
    @SalaId INT = NULL,
    @UsuarioId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ReservaId, UsuarioId, SalaId, FechaInicio, FechaFin, Estado, FechaActualizacion
    FROM dbo.Reservas
    WHERE (@SalaId IS NULL OR SalaId = @SalaId)
      AND (@UsuarioId IS NULL OR UsuarioId = @UsuarioId)
    ORDER BY ReservaId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_obtener_reserva
    @ReservaId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ReservaId, UsuarioId, SalaId, FechaInicio, FechaFin, Estado, FechaActualizacion
    FROM dbo.Reservas
    WHERE ReservaId = @ReservaId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_existe_reserva
    @ReservaId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ReservaId
    FROM dbo.Reservas
    WHERE ReservaId = @ReservaId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_cancelar_reserva
    @ReservaId INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Reservas
    SET Estado = N'CANCELADA',
        FechaActualizacion = SYSUTCDATETIME()
    OUTPUT inserted.ReservaId, inserted.UsuarioId, inserted.SalaId, inserted.FechaInicio, inserted.FechaFin, inserted.Estado, inserted.FechaActualizacion
    WHERE ReservaId = @ReservaId;
END
GO
