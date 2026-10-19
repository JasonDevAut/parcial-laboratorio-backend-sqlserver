USE CoworkingReservas;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Usuarios WHERE Email = N'ana@coworking.test')
BEGIN
    INSERT INTO dbo.Usuarios (Nombre, Apellido, Email, Telefono, PasswordHash, PerfilId)
    SELECT N'Ana', N'Rojas', N'ana@coworking.test', N'999111222',
           N'$2b$10$EklQic5lr.ZOfJKROU4eTuBR5l3F24/zC/p/8VHCuIlxTmDhYiTLu',
           PerfilId
    FROM dbo.Perfiles
    WHERE Nombre = N'Administrador';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Usuarios WHERE Email = N'luis@coworking.test')
BEGIN
    INSERT INTO dbo.Usuarios (Nombre, Apellido, Email, Telefono, PasswordHash, PerfilId)
    SELECT N'Luis', N'Paredes', N'luis@coworking.test', NULL,
           N'$2b$10$ikDVeLD1SV6PKiHT2y43fuYDEysoXlgp21w3ktXIj7TUR/0I6SwnC',
           PerfilId
    FROM dbo.Perfiles
    WHERE Nombre = N'Cliente';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Salas WHERE Nombre = N'Andes' AND Ubicacion = N'Piso 2')
BEGIN
    INSERT INTO dbo.Salas (Nombre, Capacidad, Ubicacion, Descripcion)
    VALUES (N'Andes', 8, N'Piso 2', N'Sala con pizarra');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Salas WHERE Nombre = N'Pacifico' AND Ubicacion = N'Piso 3')
BEGIN
    INSERT INTO dbo.Salas (Nombre, Capacidad, Ubicacion, Descripcion)
    VALUES (N'Pacifico', 4, N'Piso 3', NULL);
END
GO

DECLARE @UsuarioId INT;
DECLARE @SalaId INT;
DECLARE @ReservaId INT;
DECLARE @Codigo INT;

SELECT @UsuarioId = UsuarioId FROM dbo.Usuarios WHERE Email = N'ana@coworking.test';
SELECT @SalaId = SalaId FROM dbo.Salas WHERE Nombre = N'Andes' AND Ubicacion = N'Piso 2';

IF NOT EXISTS (
    SELECT 1
    FROM dbo.Reservas
    WHERE UsuarioId = @UsuarioId
      AND SalaId = @SalaId
      AND FechaInicio = '2026-11-02T10:00:00'
      AND Estado = N'CONFIRMADA'
)
BEGIN
    EXEC dbo.sp_registrar_reserva
        @UsuarioId = @UsuarioId,
        @SalaId = @SalaId,
        @FechaInicio = '2026-11-02T10:00:00',
        @FechaFin = '2026-11-02T11:00:00',
        @ReservaId = @ReservaId OUTPUT,
        @Codigo = @Codigo OUTPUT;
END
GO
