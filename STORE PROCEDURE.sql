--								STORED PROCEDURE (22)
--		RF1: Gestión de Proveedores

--01 SP para la creación, actualización y eliminación de registros de proveedores

CREATE PROCEDURE usp_MantenimientoProveedor
	@idProveedor int,
    @Nombres varchar(35),
    @Ruc varchar(11),
	@Dni varchar(8),
    @Direccion varchar(35),
    @Telefono varchar(9),
    @Email varchar(35),
    @Cuenta varchar(35),
    @Banco varchar(35),
	@Operacion int
AS
BEGIN
    IF @Operacion = 1 -- INSERTAR
		BEGIN
			INSERT INTO proveedor (idProveedor, Nombres, Ruc, Dni, Direccion, Telefono, Email, Cuenta, Banco)
			VALUES (@idProveedor, @Nombres, @Ruc, @Dni, @Direccion, @Telefono, @Email, @Cuenta, @Banco)
		END
	ELSE IF @Operacion = 2 -- ACTUALIZAR
		BEGIN
			UPDATE proveedor
			SET Nombres = @Nombres,
				Ruc = @Ruc,
				Dni = @Dni,
				Direccion = @Direccion,
				Telefono = @Telefono,
				Email = @Email,
				Cuenta = @Cuenta,
			Banco = @Banco
			WHERE idProveedor = @idProveedor
		END
	ELSE IF @Operacion = 3 -- ELIMINAR
		BEGIN
			DELETE FROM proveedor
			WHERE idProveedor = @idProveedor
		END
END
---------------------------------------------------------------------------------
--02 SP para obtener el resumen de compras de un proveedor:

CREATE PROCEDURE sp_ResumenComprasProveedor
    @idProveedor int
AS
BEGIN
    SELECT
        pro.Nombres AS Proveedor,
        c.Numero AS NumeroCompra,
        c.Fecha AS FechaCompra,
        c.Total AS TotalCompra,
        COUNT(dv.idProducto) AS CantidadProductos
    FROM compra c
    INNER JOIN detallecompra dv ON c.idCompra = dv.idCompra
    INNER JOIN producto p ON dv.idProducto = p.idProducto
	INNER JOIN proveedor pro on pro.idProveedor=c.idProveedor
    WHERE c.idProveedor = @idProveedor
    GROUP BY pro.Nombres, c.Numero, c.Fecha, c.Total
END
---------------------------------------------------------------------------------
--		RF2: Control de Medicamentos

--01 SP para agregar, editar y eliminar medicamentos en el sistema

CREATE PROCEDURE usp_MantenimientoProducto
	@idProducto int,
    @Descripcion varchar(35),
    @Concentracion varchar(30),
	@stock int,
	@Costo money, 
    @Precio_Venta money,
    @RegistroSanitario varchar(20),
    @FechaVencimiento date,
	@Estado varchar(10),
	@idPresentacion int,
	@idLaboratorio int,
	@Operacion int
BEGIN
    IF @Operacion = 1 -- INSERTAR
		BEGIN
			INSERT INTO producto(idProducto, Descripcion, Concentracion, stock, Costo, Precio_Venta, RegistroSanitario, FechaVencimiento, Estado, idPresentacion, idLaboratorio)
			VALUES (@idProducto, @Descripcion, @Concentracion, @stock, @Costo, @Precio_Venta, @RegistroSanitario, @FechaVencimiento, @Estado, @idPresentacion, @idLaboratorio)
		END
	ELSE IF @Operacion = 2
		BEGIN
			UPDATE producto -- ACTUALZAR
			SET Descripcion = @Descripcion, 
				Concentracion = @Concentracion, 
				stock = @stock, 
				Costo = @Costo, 
				Precio_Venta = @Precio_Venta, 
				RegistroSanitario = @RegistroSanitario, 
				FechaVencimiento = @FechaVencimiento, 
				Estado = @Estado, 
				idPresentacion = @idPresentacion, 
				idLaboratorio = @idLaboratorio
			WHERE idProducto = @idProducto
		END
	ELSE IF @Operacion = 3 -- ELIMINAR
		BEGIN
			DELETE FROM producto
			WHERE idProducto = @idPresentacion
		END
END
---------------------------------------------------------------------------------
--02 SP para obtener el stock bajo de productos:

CREATE PROCEDURE sp_StockBajo
    @MinStock int
AS
BEGIN
    SELECT
        p.Descripcion AS Producto,
        p.Stock AS StockActual,
        p.Precio_Venta AS PrecioVenta
    FROM producto p
    WHERE p.Stock <= @MinStock
END
-----------------------------------------------------------------------------------03 SP para actualizar Stock luego de realizar una venta

CREATE PROCEDURE sp_ActualizarStockDespuesDeVenta
(
    @idMedicamento int,
    @CantidadVendida int
)
AS
BEGIN
    UPDATE producto
    SET Stock = Stock - @CantidadVendida
    WHERE idProducto = @idMedicamento
END
---------------------------------------------------------------------------------
-- 04 SP para obtener el producto más vendido en un laboratorio

CREATE PROCEDURE SP_ProductoMasVendidoPorLaboratorioEspecifico
    @LaboratorioId INT
AS
BEGIN
    SELECT TOP 1
        p.Descripcion AS ProductoMasVendido,
        SUM(dv.Cantidad) AS TotalVendido
    FROM producto p
    INNER JOIN detalleventa dv ON p.idProducto = dv.idProducto
    WHERE p.idLaboratorio = @LaboratorioId
    GROUP BY p.Descripcion
    ORDER BY TotalVendido DESC
END
---------------------------------------------------------------------------------
-- 05 SP: Se debe poder implementar un secion de busqueda de medicamentos para poder
-- visualizar la existencia de los medicamentos en el almacen y de su stock

CREATE PROCEDURE BuscarProducto
    @criterio VARCHAR(30),
    @Prod VARCHAR(20)  
AS
BEGIN
    IF @criterio = 'Buscar' 
    BEGIN
        SELECT
            p.idProducto,pr.Descripcion AS presentacion,p.Nombre,p.Concentracion,p.Stock, p.Costo, 
			p.Precio_Venta, p.FechaVencimiento,p.RegistroSanitario,l.Nombre AS laboratorio,p.Estado
        FROM
            producto p
        INNER JOIN presentacion pr ON p.idPresentacion = pr.idPresentacion
	INNER JOIN laboratorio l ON p.idLaboratorio = l.idLaboratorio

        WHERE p.Nombre LIKE CONCAT('%',@Prod,'%');
    END 
END
---------------------------------------------------------------------------------
--06 Crear un Store Procedure en donde se esten los productos comprados por
por los clientes en un intevalo de fechas*/

create proc usp_cliente_prod_fecha
@fecha1 varchar(10),
@fecha2 varchar(10)
as
 select producto.Nombre,compra.idUsuario,compra.fecha
 from compra 
 inner join detallecompra on compra.idCompra=detallecompra.idCompra 
 inner join producto detallecomora.idProducto=producto.idProducto 
 where Fecha between @fecha1 and @fecha2

---------------------------------------------------------------------------------
--		RF3: Registro de Clientes

--01 SP para la creación, actualización y eliminación de registros de clientes

CREATE PROCEDURE usp_MantenimientoCliente
	@idCliente int,
    @Nombres varchar(35),
    @Apellidos varchar(35),
	@Genero char(1),
	@Dni varchar(8), 
    @Telefono varchar(9),
    @Ruc varchar(11),
    @Direccion varchar(50),
	@Operacion int
AS
BEGIN
    IF @Operacion = 1 -- INSERTAR
		BEGIN
			INSERT INTO cliente(idCliente, Nombres, Apellidos, Genero, Dni, Telefono, Ruc, Direccion)
			VALUES (@idCliente, @Nombres, @Apellidos, @Genero, @Dni, @Telefono, @Ruc, @Direccion)
		END
	ELSE IF @Operacion = 2
		BEGIN
			UPDATE cliente -- ACTUALZAR
			SET
				Nombres = @Nombres, 
				Apellidos = @Apellidos, 
				Genero = @Genero, 
				Dni = @Dni,	 
				Telefono = @Telefono, 
				Ruc =@Ruc, 
				Direccion = @Direccion
			WHERE idCliente = @idCliente
		END
	ELSE IF @Operacion = 3 -- ELIMINAR
		BEGIN
			DELETE FROM cliente
			WHERE idCliente = @idCliente
		END
END
---------------------------------------------------------------------------------
--		RF4: Administración de Empleados

--01 SP para agregar, actualizar y eliminar registros de empleados.

CREATE PROCEDURE usp_MantenimientoEmpleados
	@idEmpleado int,
    @Nombres varchar(35),
    @Apellidos varchar(30),
	@Cargo varchar(30),
	@Dni varchar(8), 
    @Telefono varchar(9),
    @Direccion varchar(50),
    @FechaLaboral date,
	@HoraIngreso time,
	@HoraSalida time,
	@Sueldo money,
	@IdUsuario INT,
	@Operacion int
AS
BEGIN
    IF @Operacion = 1 -- INSERTAR
	BEGIN
		INSERT INTO empleado (idEmpleado, Nombres, Apellidos, Cargo, Dni, Telefono, Direccion, FechaLaboral, HoraIngreso, HoraSalida, Sueldo, idUsuario)
		VALUES (@idEmpleado, @Nombres, @Apellidos, @Cargo, @Dni, @Telefono, @Direccion, @FechaLaboral, @HoraIngreso, @HoraSalida, @Sueldo, @IdUsuario)
	END
	ELSE IF @Operacion = 2
		BEGIN UPDATE empleado -- ACTUALZAR
			SET Nombres = @Nombres,
				Apellidos = @Apellidos,
				Cargo = @Cargo,
				Dni = @Dni,
				Telefono = @Telefono,
				Direccion = @Direccion,
				FechaLaboral = @FechaLaboral,
				HoraIngreso = @HoraIngreso,
				HoraSalida = @HoraSalida,
				Sueldo = @Sueldo,
				idUsuario = @IdUsuario
        WHERE idEmpleado = @IdEmpleado
		END
	ELSE IF @Operacion = 3 -- ELIMINAR
		BEGIN
			DELETE FROM empleado
			WHERE idEmpleado = @IdEmpleado
		END
END
--02 SP para el detalle de la venta de un empelado por su id
CREATE PROCEDURE ConsultaDetalleVentaDeEmpleado
@idEmpleado INT,
@idVenta INT
AS
BEGIN
    SELECT dv.IdVenta, dv.idProducto, p.Descripcion AS Producto, dv.Cantidad, dv.Costo, dv.Precio, dv.Importe
    FROM detalleventa dv
    JOIN producto p ON dv.idProducto=p.idProducto
    JOIN ventas v ON dv.IdVenta=v.IdVenta
    WHERE v.idEmpleado=@idEmpleado AND dv.IdVenta=@idVenta
END
---------------------------------------------------------------------------------
--03 SP para todas las ventas realizadas de cierto empleado, en un rango de fechas
CREATE PROCEDURE SP_ConsultaVentasPorEmpleado
@idEmpleado INT,
@FechaInicio DATE,
@FechaFin DATE
AS
BEGIN
    SELECT v.IdVenta, v.Serie, v.Numero, v.Fecha, v.VentaTotal, v.Descuento, v.SubTotal, v.Igv
    FROM ventas v
    WHERE v.idEmpleado=@idEmpleado AND v.Fecha BETWEEN @FechaInicio AND @FechaFin
END
---------------------------------------------------------------------------------
--04 SP para mostrar los empleados con más ventas y la total de sus ventas entre dos fechas
CREATE PROCEDURE SP_ConsultaEmpleadosConMasVentasEntreFechas
@FechaInicio DATE,
@FechaFin DATE
AS
BEGIN
    SELECT e.idEmpleado, e.Nombres, e.Apellidos, COUNT(v.IdVenta) TotalVentas, SUM(v.VentaTotal) TotalVentasMonto
    FROM empleado e
    LEFT JOIN ventas v ON e.idEmpleado=v.idEmpleado
    WHERE v.Fecha BETWEEN @FechaInicio AND @FechaFin
    GROUP BY e.idEmpleado, e.Nombres, e.Apellidos
    ORDER BY TotalVentas DESC
END
---------------------------------------------------------------------------------
--05 SP para calcular la comisión de un empleado en base a sus ventas:

CREATE PROCEDURE sp_CalcularComisionEmpleado
    @idEmpleado int,
    @PorcentajeComision decimal(5, 2) = 0.05
AS
BEGIN
    DECLARE @TotalVentas decimal(8, 2)
    SELECT @TotalVentas = SUM(v.Total)
    FROM ventas v
    WHERE v.idEmpleado = @idEmpleado
    DECLARE @Comision decimal(8, 2)
    SET @Comision = @TotalVentas * @PorcentajeComision
    SELECT
        e.Nombres + ' ' + e.Apellidos AS Empleado,
        @TotalVentas AS TotalVentas,
        @PorcentajeComision AS PorcentajeComision,
        @Comision AS ComisionCalculada from empleado e
END
---------------------------------------------------------------------------------
/*06.crear un Store Procedure la cantidad de empleados que trabajan en la farmacia 
     duarnte el mes y semana*/

CREATE PROC usp_empleado_fecha
    @semana int,
    @mes int
AS
BEGIN
    SELECT 
        COUNT(*) AS TotalEmpleados,
        DATEPART(week, empleado.FechaLaboral) AS Semana,
        DATEPART(MONTH, empleado.FechaLaboral) AS Mes
    FROM 
        empleado
    WHERE 
        DATEPART(week, empleado.FechaLaboral) = @semana AND 
        DATEPART(MONTH, empleado.FechaLaboral) = @mes;
END
---------------------------------------------------------------------------------
--	RF5: Gestión de ventas y compras

--01 SP para aplicar descuento a productos próximos a vencer

CREATE PROCEDURE SP_AplicarDescuentosProductosProximosAVencer
    @DiasRestantes INT,
    @DescuentoPorcentaje DECIMAL(5, 2)
AS
BEGIN
    UPDATE producto
    SET Precio_Venta = Precio_Venta * (1 - @DescuentoPorcentaje / 100)
    WHERE DATEDIFF(DAY, GETDATE(), FechaVencimiento) <= @DiasRestantes
END
---------------------------------------------------------------------------------
--02 SP El sistema debe buscar las compras realizadas, incluyendo información sobre 
el proveedor, empleado, fecha y monto total de la compra*/

CREATE PROCEDURE ComprasPorFecha 
	@criterio VARCHAR(30), 
	@fechaInicio DATE, 
	@fechaFin DATE  
AS
BEGIN
		IF @criterio = 'Buscar' 
			SELECT c.idCompra,p.Nombres AS proveedor, c.Fecha, CONCAT(u.Nombres, ' ' ,u.Apellidos) AS empleado,
			copr.Descripcion AS tipocomprobante,c.Numero,c.Total  
			FROM compra AS c
			INNER JOIN proveedor p 
			ON c.idProveedor=p.IdProveedor
				INNER JOIN usuario u
				ON c.idUsuario=u.idUsuario
				INNER JOIN comprobante copr 
				ON c.idcomprobante=copr.idcomprobante
			WHERE (c.Fecha >=@fechaInicio AND c.Fecha<=@fechaFin) 
			ORDER BY c.idCompra DESC;
	END
---------------------------------------------------------------------------------
--03 crear un store procedure la cantidad de empleados y el promedio de ventas por día

CREATE PROCEDURE sp_PromedioVentasPorDia
    @FechaInicio DATE,
    @FechaFin DATE
AS
BEGIN
    SELECT 
        v.Fecha,
        COUNT(DISTINCT v.idEmpleado) AS CantidadEmpleados,
        AVG(v.VentaTotal) AS PromedioVentas
    FROM Ventas v inner join empleado e on v.idEmpleado=e.idEmpleado
    WHERE v.Fecha BETWEEN @FechaInicio AND @FechaFin
    ORDER BY v.Fecha
END
--04 Store procedure para listar empleados con sus ventas en intervalo 
     de fechas en una tabla temporal llamada  ##listar_empleado*/
CREATE PROCEDURE sp_ListarEmpleadosConVentas
    @FechaI DATE,
    @FechaF DATE
AS
BEGIN
    CREATE TABLE ##listar_empleado
    (
        idEmpleado INT,
        Nombre VARCHAR(20),
        FechaVenta DATE,
        MontoVenta DECIMAL(10, 2)
		)
    INSERT INTO ##listar_empleado (EmpleadoID, Nombre, FechaVenta, MontoVenta)
    SELECT e.idEmpleado, e.Nombre, v.Fecha, v.VentaTotal
    FROM empleado e
    INNER JOIN  ventas v ON e.idEmpleado = v.idEmpleado
    WHERE v.Fecha BETWEEN @FechaI AND @FechaF
    SELECT * FROM ##listar_empleado;
END
---------------------------------------------------------------------------------
--	RF6: Detalles de Ventas

--01	Se debe poder consultar los detalles de cada venta, incluyendo nombre,
--	descripcion del producto total del importe y ganacia
CREATE PROCEDURE VentasPorDetalle
    @criterio VARCHAR(30),
    @fechaIni DATE,
    @fechaFin DATE
AS
BEGIN
    IF @criterio = 'consultar'
    BEGIN
        SELECT
            p.idProducto,p.Nombre,pr.Descripcion,dv.Costo, dv.Precio,SUM(dv.Cantidad) AS TotalCantidad,
            SUM(dv.Importe) AS Total_Importe,SUM(dv.Importe - (dv.Costo * dv.Cantidad)) AS GananciaTotal
        FROM
            ventas v
        INNER JOIN detalleventa dv 
		ON v.IdVenta = dv.IdVenta
			INNER JOIN producto p 
			ON dv.idProducto = p.idProducto
				INNER JOIN presentacion pr 
				ON p.idPresentacion = pr.idPresentacion
        WHERE
            (v.Fecha >= @fechaIni AND v.Fecha <= @fechaFin)
        GROUP BY p.idProducto, p.Nombre,pr.Descripcion,dv.Costo,dv.Precio;
    END
    ELSE
    BEGIN
        PRINT 'criterio invalido usar "consultar" '
    END
END
---------------------------------------------------------------------------------
--RF9: Reportes de Inventario
--01 SP para obtener un informe de ventas por mes:

CREATE PROCEDURE sp_InformeVentasPorMes
    @Anio int,
    @Mes int
AS
BEGIN
    SELECT
        DATEPART(YEAR, v.Fecha) AS Anio,
        DATEPART(MONTH, v.Fecha) AS Mes,
        COUNT(v.IdVenta) AS NumeroVentas,
        SUM(v.Total) AS TotalVentas
    FROM ventas v
    WHERE DATEPART(YEAR, v.Fecha) = @Anio AND DATEPART(MONTH, v.Fecha) = @Mes
    GROUP BY DATEPART(YEAR, v.Fecha), DATEPART(MONTH, v.Fecha)
END
---------------------------------------------------------------------------------
--RF11: Alertas de caducidad
--01	Advierte de productos pronto a caducar

CREATE PROCEDURE SP_AlertasCaducidadMedicamentos
AS
BEGIN
   
    DECLARE @PlazoCaducidad INT
    SET @PlazoCaducidad = 30

    DECLARE @FechaLimite DATE
    SET @FechaLimite = DATEADD(DAY, @PlazoCaducidad, GETDATE())

    SELECT p.idProducto, p.Descripcion, p.FechaVencimiento
    FROM producto p
    WHERE p.Estado = 'Disponible' AND p.FechaVencimiento <= @FechaLimite
END
