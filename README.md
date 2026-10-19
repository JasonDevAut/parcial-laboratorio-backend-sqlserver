# Base de datos SQL Server

Este directorio es el repositorio de la base transaccional. La API Node.js y los scripts de MongoDB se entregan en repositorios aparte.

La base se llama `CoworkingReservas`.

## Docker

Desde este directorio:

```text
docker compose up -d
```

Levanta SQL Server en `localhost:1433` con el usuario `sa` y la contraseña `Coworking!2026`. No crea la base ni ejecuta scripts: eso lo aplica un DBA, en el orden de abajo, cuando el motor ya está en marcha.

```text
sqlcmd -S localhost,1433 -U sa -P "Coworking!2026" -C -i DDL/01-tablas.sql
sqlcmd -S localhost,1433 -U sa -P "Coworking!2026" -C -i DDL/02-indices.sql
sqlcmd -S localhost,1433 -U sa -P "Coworking!2026" -C -i DDL/03-stored-procedure.sql
sqlcmd -S localhost,1433 -U sa -P "Coworking!2026" -C -i DDL/04-seguridad.sql
sqlcmd -S localhost,1433 -U sa -P "Coworking!2026" -C -i DDL/05-fecha-actualizacion.sql
sqlcmd -S localhost,1433 -U sa -P "Coworking!2026" -C -i DML/01-carga-inicial.sql
```

## Orden de ejecución

DDL, definición de la base:

1. `DDL/01-tablas.sql` crea la base y las tablas `Perfiles`, `Usuarios`, `Salas` y `Reservas`.
2. `DDL/02-indices.sql` crea el índice de solapamiento y el índice por usuario.
3. `DDL/03-stored-procedure.sql` crea los procedimientos de usuarios, salas y reservas.
4. `DDL/04-seguridad.sql` crea los perfiles `Administrador` y `Cliente`, y completa clave y perfil en una base que ya existía.
5. `DDL/05-fecha-actualizacion.sql` agrega `FechaActualizacion` a usuarios, salas y reservas si la columna no existe.

DML, carga de datos:

6. `DML/01-carga-inicial.sql` inserta usuarios, salas y una reserva usando el procedimiento. Ana queda como administradora y Luis como cliente.

No hay scripts DCL: estos archivos no conceden ni revocan permisos.

El mismo orden con autenticación de Windows:

```text
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -i DDL/01-tablas.sql
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -i DDL/02-indices.sql
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -i DDL/03-stored-procedure.sql
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -i DDL/04-seguridad.sql
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -i DDL/05-fecha-actualizacion.sql
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -i DML/01-carga-inicial.sql
```

`DDL/01-tablas.sql` vuelve a crear las tablas si ya existen. Ejecutarlo de nuevo borra los datos de esas tablas.

El diagrama entidad-relación está en `diagrama.md`.
