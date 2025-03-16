-- CURSORES 5

-- RF3: GESTION DE CLIENTES
--1)	Crear un cursor para recorrer los registros de cliente

DECLARE @idCliente INT
DECLARE @Direccion VARCHAR(50)
DECLARE actualizarDireccion CURSOR FOR
SELECT idCliente, Direccion
FROM cliente

OPEN actualizarDireccion
SET @Direccion = 'Sin dirección'

FETCH NEXT FROM actualizarDireccion INTO @idCliente, @Direccion
WHILE @@FETCH_STATUS = 0
BEGIN
    IF @Direccion IS NULL
    BEGIN
        UPDATE cliente
        SET Direccion = @Direccion
        WHERE idCliente = @idCliente
    END
    FETCH NEXT FROM actualizarDireccion INTO @idCliente, @Direccion
END
CLOSE actualizarDireccion
DEALLOCATE actualizarDireccion
---------------------------------------------------------------------------------
--RF4: Administración de Empleados
--Un cursor para recorrer los registros de la tabla "empleado" e imprimir información sobre cada empleado.
DECLARE @idEmpleado int
DECLARE @Nombres varchar(35)
DECLARE @Apellidos varchar(35)
DECLARE @Sueldo float

DECLARE cursorEmpleados CURSOR FOR
SELECT idEmpleado, Nombres, Apellidos, Sueldo
FROM empleado

OPEN cursorEmpleados
FETCH NEXT FROM cursorEmpleados INTO @idEmpleado, @Nombres, @Apellidos, @Sueldo

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Empleado: ' + @Nombres + ' ' + @Apellidos
    PRINT 'Sueldo: ' + CAST(@Sueldo AS varchar(10))
    PRINT '------------------------'

    FETCH NEXT FROM cursorEmpleados INTO @idEmpleado, @Nombres, @Apellidos, @Sueldo
END

CLOSE cursorEmpleados
DEALLOCATE cursorEmpleados
---------------------------------------------------------------------------------
-- RF8: Autenticación de Usuarios
--01 un cursor que modificar los gmail de los empleados para una mejor administracion 

DECLARE @idus int
DECLARE @dni varchar(9)
DECLARE @nombre varchar(35)

DECLARE cursor_usuario 
SCROLL CURSOR 
FOR
	SELECT idUsuario,Dni,Nombres
	FROM usuario

	OPEN  cursor_usuario  
	FETCH NEXT FROM  cursor_usuario 
		INTO @idus,
				@dni,
				@nombre
		WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE usuario
			SET Email = LOWER(SUBSTRING(@nombre,1,4))+@dni+'@gmail.com'
			WHERE idUsuario = @idus
			PRINT  ' Cambio ejecutado exitosamente '

			FETCH NEXT FROM  cursor_usuario 
				INTO @idus,
						@dni,
						@nombre

		END
	CLOSE cursor_usuario 
	DEALLOCATE  cursor_usuario 
---------------------------------------------------------------------------------
 
--RF9: Reportes de Inventario

--01 Un cursor que emite un listado de productos sin stock 
     y que sus precios superen 5 y no exceda de 13.*/
DECLARE @idProducto INT
DECLARE @nombre VARCHAR(50)
DECLARE @stock INT
DECLARE @precio_venta MONEY
DECLARE @costo MONEY
DECLARE @mensaje VARCHAR(100)

DECLARE cursor_producto CURSOR 
  FOR 
	SELECT P.idProducto,P.nombre,P.stock,P.precio_venta,P.costo
	FROM Producto P
	WHERE (precio_venta BETWEEN 5 AND 13) AND stock IS NULL 
OPEN cursor_producto
FETCH NEXT FROM cursor_producto INTO @idProducto, @nombre,@stock,@precio_venta,@costo 
WHILE @@FETCH_STATUS=0
BEGIN
  SET @mensaje = cast (@idProducto as varchar(10))+' '+@nombre+' '+cast (@stock as varchar(10))+' '+
                 cast (@precio_venta as varchar(10)+' '+cast (@costo as varchar(10))
  PRINT (@mensaje)
  FETCH NEXT FROM cursor_producto 
	INTO  @idProducto, @nombre,@stock,@precio_venta,@costo 
END
CLOSE cursor_producto
DEALLOCATE cursor_producto
---------------------------------------------------------------------------------
--RF11: Alertas de Caducidad

--01 Nombre y fecha de caducidad de medicamente pronto a vencer

DECLARE @NombreMedicamento VARCHAR(35)
DECLARE @FechaVencimiento DATE

DECLARE medicamentosCursor CURSOR FOR
SELECT Descripcion, FechaVencimiento
FROM producto
WHERE DATEDIFF(DAY, GETDATE(), FechaVencimiento) <= 30

-- Abrir el cursor
OPEN medicamentosCursor

FETCH NEXT FROM medicamentosCursor INTO @NombreMedicamento, @FechaVencimiento
WHILE @@FETCH_STATUS = 0
BEGIN
    
    PRINT 'Nombre del Medicamento: ' + @NombreMedicamento
    PRINT 'Fecha de Vencimiento: ' + CONVERT(NVARCHAR(10), @FechaVencimiento, 120)

    FETCH NEXT FROM medicamentosCursor INTO @NombreMedicamento, @FechaVencimiento
END

CLOSE medicamentosCursor
DEALLOCATE medicamentosCursor
