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

use farmacia02
-------------------------------------------------------

-- TABLAS
CREATE TABLE cliente (
idCliente int NOT NULL,
Nombres varchar(35) NOT NULL,
Apellidos varchar(35) NOT NULL,
Genero char(1) CHECK (Genero IN ('M', 'F')),
Dni varchar(8) NOT NULL
			Constraint aDni Default '999999999'	
			Constraint bDni Check (Dni like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
Telefono varchar(9)
			Constraint aTelf Default '000000000'	
			Constraint bTelf Check (Telefono like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
Ruc varchar(11)
			Constraint aRuc Default '11111111111'	
			Constraint bRuc Check (Ruc like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
Direccion varchar(50),
PRIMARY KEY (idCliente)
)

CREATE TABLE usuario (
idUsuario int NOT NULL,
Nombres varchar(35) NOT NULL,
Apellidos varchar(35) NOT NULL,
Dni varchar(8)	NOT NULL
				Constraint cDni Default '999999999'	
				Constraint dDni Check (Dni like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
Email varchar(35),
Usuario varchar(30) NOT NULL,
Contraseña varchar(30) NOT NULL,
TipoUsuario varchar(20) NOT NULL,
PRIMARY KEY (idUsuario),
)

CREATE TABLE empleado (
idEmpleado int NOT NULL,
Nombres varchar(35) NOT NULL,
Apellidos varchar(35) NOT NULL,
Cargo varchar(30) NOT NULL,
Dni varchar(8) NOT NULL
				Constraint eDni Default '999999999'	
				Constraint fDni Check (Dni like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
Telefono varchar(9)
			Constraint cTelf Default '000000000'	
			Constraint dTelf Check (Telefono like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
Direccion varchar (50),
FechaLaboral date , -- Dia Laborado
HoraIngreso time ,	-- Horas de trabajo
HoraSalida time ,	-- Horas de trabajo
Sueldo money NOT NULL check(Sueldo >= 0),
idUsuario int NOT NULL,
PRIMARY KEY (idEmpleado),
FOREIGN KEY (idUsuario) REFERENCES usuario (idUsuario)
)

CREATE TABLE presentacion (
idPresentacion int NOT NULL,
Descripcion varchar(35),
Estado varchar(30),
PRIMARY KEY (idPresentacion)
)

CREATE TABLE laboratorio (
idLaboratorio int NOT NULL,
Nombre varchar(35) NOT NULL,
Direccion varchar(35) NOT NULL,
Telefono varchar(9)
			Constraint eTelf Default '000000000'	
			Constraint fTelf Check (Telefono like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
Ruc varchar(11)
			Constraint cRuc Default '11111111111'	
			Constraint dRuc Check (Ruc like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
PRIMARY KEY (idLaboratorio)
)

CREATE TABLE producto (
idProducto int NOT NULL,
Descripcion varchar(35) NOT NULL,
Concentracion varchar(30),
Stock int NOT NULL check(Stock>=0),
Costo money NOT NULL check(Costo>=0),
Precio_Venta money NOT NULL check(Precio_Venta>=0),
RegistroSanitario varchar(20) ,
FechaVencimiento date NOT NULL,
Estado varchar(10),
idPresentacion int NOT NULL,
idLaboratorio int NOT NULL,
PRIMARY KEY (idProducto),
FOREIGN KEY (idLaboratorio) REFERENCES laboratorio (idLaboratorio),
FOREIGN KEY (idPresentacion) REFERENCES presentacion (idPresentacion)
)

CREATE TABLE proveedor (
idProveedor int NOT NULL,
Nombres varchar(35) NOT NULL,
Ruc varchar(11) 
			Constraint eRuc Default '11111111111'	
			Constraint fRuc Check (Ruc like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
Dni varchar(8)
				Constraint gDni Default '999999999'	
				Constraint hDni Check (Dni like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
Direccion varchar(35) ,
Telefono varchar(9) 
			Constraint gTelf Default '000000000'	
			Constraint hTelf Check (Telefono like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
Email varchar(35) ,
Cuenta varchar(35) ,
Banco varchar(35) ,
PRIMARY KEY (idProveedor)
)

CREATE TABLE tipo (
idTipo int NOT NULL,
compraventa varchar(35) NOT NULL,
PRIMARY KEY (idTipo)
)

CREATE TABLE comprobante (
idcomprobante int NOT NULL,
Descripcion varchar(35) NOT NULL,
Estado varchar(10),
idTipo int foreign key references tipo(idTipo),
PRIMARY KEY (idcomprobante),
)

CREATE TABLE compra (
idCompra int NOT NULL,
Numero varchar(15) NOT NULL,
Fecha date NOT NULL,
TipoPago varchar(30) NOT NULL,
idProveedor int NOT NULL,
idUsuario int NOT NULL,
idcomprobante int NOT NULL,
SubTotal money NOT NULL check(SubTotal >=0),
Igv money NOT NULL check(IGV >=0),
Total money NOT NULL check(Total >=0),
PRIMARY KEY (idCompra),
FOREIGN KEY (idcomprobante) REFERENCES comprobante (idcomprobante),
FOREIGN KEY (idUsuario) REFERENCES usuario (idUsuario),
FOREIGN KEY (idProveedor) REFERENCES proveedor (IdProveedor)
)

CREATE TABLE detallecompra (
idCompra int NOT NULL,
idProducto int NOT NULL,
Cantidad int NOT NULL check(Cantidad >= 0),
Costo money NOT NULL check(Costo >= 0),
Importe money NOT NULL check(Importe >= 0),
FOREIGN KEY (idProducto) REFERENCES producto (idProducto),
FOREIGN KEY (idCompra) REFERENCES compra (idCompra)
)

CREATE TABLE ventas (
IdVenta int NOT NULL,
Serie varchar(10) NOT NULL,
Numero varchar(20) NOT NULL,
Fecha date NOT NULL,
idCliente int NOT NULL,
idEmpleado int NOT NULL,
idcomprobante int NOT NULL,
VentaTotal money NOT NULL check(VentaTotal >=0),
Descuento money NOT NULL check(Descuento >=0),
SubTotal money NOT NULL check(SubTotal >= 0),
Igv money NOT NULL check(IGV >=0),
Total money NOT NULL check (Total >=0),
PRIMARY KEY (IdVenta),
FOREIGN KEY (idcomprobante) REFERENCES comprobante (idcomprobante),
FOREIGN KEY (idCliente) REFERENCES cliente (idCliente),
FOREIGN KEY (idEmpleado) REFERENCES empleado (idEmpleado),
)

CREATE TABLE detalleventa (
IdVenta int NOT NULL,
idProducto int NOT NULL,
Cantidad int NOT NULL check(Cantidad>=0),
Costo money NOT NULL check(Costo>=0),
Precio money NOT NULL check (Precio>=0),
Importe money NOT NULL check(Importe>=0),
FOREIGN KEY (idProducto) REFERENCES producto (idProducto),
FOREIGN KEY (IdVenta) REFERENCES ventas (IdVenta)
)
