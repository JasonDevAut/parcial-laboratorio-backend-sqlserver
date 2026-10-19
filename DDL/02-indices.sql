USE CoworkingReservas;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Reservas_Sala_Estado_Fechas'
      AND object_id = OBJECT_ID(N'dbo.Reservas')
)
BEGIN
    CREATE INDEX IX_Reservas_Sala_Estado_Fechas
        ON dbo.Reservas (SalaId, Estado, FechaInicio, FechaFin);
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Reservas_UsuarioId'
      AND object_id = OBJECT_ID(N'dbo.Reservas')
)
BEGIN
    CREATE INDEX IX_Reservas_UsuarioId
        ON dbo.Reservas (UsuarioId);
END
GO
