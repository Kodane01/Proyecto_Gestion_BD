USE master
-- ELIMINAR LA BASE DE DATOS SI EXISTE
IF EXISTS ( SELECT name
            FROM sysdatabases
            WHERE name IN ('farmacia02')) 	
BEGIN
    DROP DATABASE farmacia02
END
------------------------------------------------------
-- CREAR DE BASE DE DATOS 
CREATE DATABASE farmacia02 -- (SOLO EJECUTAR ESTA LÍNEA)
ON PRIMARY
(
NAME = 'farmacia02_Data',
FILENAME = 'D:\Base_DatosII\Proyecto_Final\Data\farmacia02.mdf',
SIZE = 120MB,
MAXSIZE = 900MB,
FILEGROWTH = 10%
)

LOG ON
(
NAME = 'farmacia02_Log',
FILENAME = 'D:\Base_DatosII\Proyecto_Final\Data\farmacia02.ldf',
SIZE = 100MB,
MAXSIZE = 800MB,
FILEGROWTH = 15%
)
USE farmacia02
------------------------------------------------------------
-- CREAR EL BACKUP DE LA BASE DE DATOS FARMACIA
------------------------------------------------------------
BACKUP DATABASE farmacia02
TO DISK = 'D:\Base_DatosII\Proyecto_Final\Data\farmacia02'
------------------------------------------------------------
-- RESTAURAR EL BACKUP
------------------------------------------------------------
RESTORE DATABASE farmacia02 
FROM DISK = 'D:\Base_DatosII\Proyecto_Final\Data\farmacia02'
