---------------------------------------------------------------------------------
TRIGGERS
--PRIMER TRIGGER EN AFTER
--RF2: Control de Medicamentos

--01 Este trigger es actualizar la cantidad de stock de un producto después de que se inserta 
--un nuevo registro en la tabla DetalleCompra.
CREATE TRIGGER tr_AfterInsertDetalleCompra
ON DetalleCompra
FOR INSERT
AS
BEGIN
    DECLARE @idProducto int
    DECLARE @Cantidad int

    SELECT @idProducto = idProducto, @Cantidad = Cantidad
    FROM inserted

    UPDATE producto
    SET Stock = Stock - @Cantidad
    WHERE idProducto = @idProducto
END
---------------------------------------------------------------------------------

--02 El propósito de este trigger es limitar la cantidad de productos que se pueden 
--insertar en la tabla detallecompra a un máximo de 100 unidades. 
CREATE TRIGGER tr_InsteadOfInsertDetalleCompraLimit
ON detallecompra
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @MaxCantidad int = 100

    INSERT INTO detallecompra (idCompra, idProducto, Cantidad, Costo, Importe)
    SELECT idCompra, idProducto, Cantidad, Costo, Importe
    FROM inserted
    WHERE Cantidad <= @MaxCantidad

    IF EXISTS (SELECT * FROM inserted WHERE Cantidad > @MaxCantidad)
    BEGIN
        PRINT ('La cantidad de productos excede el límite permitido.')
    END
END

--RF3: Registro de Clientes
--01 Trigger para registrar algun cambio de insercion de clientes */
CREATE TRIGGER tr_ins_cliente
on cliente
for insert
as
   declare @idcliente int
   declare @nombrecliente varchar(20)
   declare @fecha varchar(8)
   
   set @idcliente=(select idcliente from inserted)
   set @nombre=(select nombrecliente from         
                 cliente where idcliente=@idcli)
   set @fecha=(select fecha from  inserted)

   insert t_cliente values(@idcli,@nombre,@fecha)   
--RF4: Administración de empleados

--01 TRIGGER DE ACTUALIZACION, PARA CONTROLAR LOS CAMBIOS DEL CAMPO SUELDO DE UN EMPLEADO
--EN UNA TABLA DE REGISTRO CON EL NOMBRE DE REGISTRO_SUELDOS
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='registro_sueldos')
BEGIN
    CREATE TABLE registro_sueldos (
        idRegistro INT IDENTITY(1,1) PRIMARY KEY,
        idEmpleado INT,
        SueldoAnterior DECIMAL(18, 2),
        SueldoNuevo DECIMAL(18, 2),
        FechaModificacion DATETIME
    )
END

CREATE TRIGGER TR_ActualizarSueldo
ON empleados
AFTER UPDATE
AS
BEGIN
    INSERT INTO registro_sueldos(idEmpleado, SueldoAnterior, SueldoNuevo, FechaModificacion)
    SELECT
        i.idEmpleado,
        d.Sueldo  SueldoAnterior,
        i.Sueldo  SueldoNuevo,
        GETDATE() AS FechaModificacion
    FROM inserted i
    JOIN deleted d ON i.idEmpleado=d.idEmpleado
END

---------------------------------------------------------------------------------
--02 Trigger que verifica si el salario es mayor o igual al minimo

CREATE TRIGGER trg_ValidarSalarioBeforeUpdate
ON empleado
instead of UPDATE
AS
BEGIN
    
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.Sueldo < 1250
    )
    BEGIN
        -- Cancelar la actualización
        ROLLBACK TRANSACTION;
    END
END
---------------------------------------------------------------------------------
--03 trigger nuevo empleado
CREATE TRIGGER Trigger_Empleado
ON empleado
AFTER INSERT
AS
BEGIN
    DECLARE @NuevoEmpleadoNombre VARCHAR(50)
    DECLARE @Mensaje VARCHAR(100)

    SELECT @NuevoEmpleadoNombre = Nombres + ' ' + Apellidos
    FROM inserted

    SET @Mensaje = 'Se ha añadido un nuevo empleado: ' + @NuevoEmpleadoNombre

    PRINT @Mensaje
END
---------------------------------------------------------------------------------
--		RF6: Detalles de Ventas

--01 CREAR TRIGGER PARA CALCULAR EL TOTAL DE LA VENTA
CREATE TRIGGER tr_calcular_subtotal_igv_total
ON ventas
AFTER INSERT
AS
BEGIN
    DECLARE @idVenta INT
    DECLARE @ventaTotal MONEY
    DECLARE @descuento MONEY
    DECLARE @subTotal MONEY
    DECLARE @igv MONEY
    DECLARE @total MONEY

    SELECT @idVenta = IdVenta, 
		   @ventaTotal = VentaTotal,
           @descuento = Descuento
    FROM inserted

    SET @subTotal = @ventaTotal - @descuento
    SET @igv = @subTotal * 0.18 
    PRINT 'IGV INCLUIDO'
	SET @total = @subTotal + @igv
	PRINT 'VENTA EXITOSA'

    UPDATE VENTAS
    SET SubTotal = @subTotal,
        Igv = @igv,
        Total = @total
    WHERE
---------------------------------------------------------------------------------
--RF9: Reportes de Inventario

--01 Trigger que permita reducir el stock de un producto, luego de una venta

CREATE TRIGGER tg_VENTA
ON detalleVenta
for insert
as
declare @idProducto int
declare @stock int
declare @cantidad int

set @cantidad=(select cantidad from inserted)
set @idProducto =(select idProducto from inserted)
set @stock=(select stock from producto where idProducto=@idProducto)
if (@cantidad>0)
   begin
   if (@stock<=2)
   begin
   raiserror ('stock insuficiente')
   --ANULA EL EVENTO DE INSERT
   rollback transaction
   end
   else
   begin
   --ACTUALIZAMOS LA TABLA PRODUCTO, STOCK Y REDUCIMOS
   update producto set
   stock=stock-@cantidad 
   where idProducto=@idProducto
   end
   end
else
 raiserror('la cantidad no es correcta')
 rollback transaction
end
---------------------------------------------------------------------------------
--RF10: Seguimiento de Ventas
-- Trigger que registra ventas en historial de ventas

CREATE TRIGGER trg_RegistrarVentaAfterInsert
ON ventas
AFTER INSERT
AS
BEGIN
    
    INSERT INTO historial_ventas (idVenta, FechaVenta, MontoTotal)
    SELECT IdVenta, Fecha, Total
    FROM inserted;
END;

---------------------------------------------------------------------------------
--		RF12: Historial de Cambios
--01 Crear un trigger de auditoria para los proveedores.

CREATE TABLE HistorialProveedor_ins (
    IdProveedor INT,
	Nombres varchar(35),
    RUC varchar(11),
	Dni varchar(8),
    FechaCambio DATETIME,
    Usuario VARCHAR(50),
    Motivo varchar(max)
)

CREATE TABLE HistorialProveedor_del (
    IdProveedor INT,
    Nombres varchar(35),
    RUC varchar(11),
	Dni varchar(8),
    FechaCambio DATETIME,
    Usuario VARCHAR(50),
    Motivo varchar(max)
)

-- TRIGGER

CREATE TRIGGER tr_historial_cambios_proveedor
ON proveedor
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @ins INT
    DECLARE @del INT
    DECLARE @Motivo VARCHAR(MAX)

    SET @ins = (SELECT COUNT(*) FROM inserted)
    SET @del = (SELECT COUNT(*) FROM deleted)

    IF @ins > 0 AND @del = 0
    BEGIN
        SET @Motivo = 'Inserción'
		PRINT @Motivo
    END
    
	ELSE IF @ins > 0 AND @del > 0
    BEGIN
        SET @Motivo = 'Actualización'
		PRINT @Motivo
    END
    
	ELSE IF @ins = 0 AND @del > 0
    BEGIN
        SET @Motivo = 'Eliminación'
		PRINT @Motivo
    END

    INSERT INTO HistorialProveedor_ins (IdProveedor, Nombres, RUC, Dni, FechaCambio, Usuario, Motivo)
    SELECT IdProveedor, Nombres, RUC, Dni, GETDATE(), SYSTEM_USER, @Motivo
    FROM inserted

	INSERT INTO HistorialProveedor_del (IdProveedor, Nombres, RUC, Dni, FechaCambio, Usuario, Motivo)
    SELECT IdProveedor, Nombres, RUC, Dni, GETDATE(), SYSTEM_USER, @Motivo
    FROM deleted
END
