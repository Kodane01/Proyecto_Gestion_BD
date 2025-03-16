FUNCIONES (15)
--RF1: Gestión de Proveedores
--01 Calcular monto total de compras de un proveedor en un periodo de tiempo
CREATE FUNCTION fn_MontoTotalComprasProveedor
(	@idProveedor int,
    @FechaInicio date,
    @FechaFin date)
RETURNS money
AS
BEGIN
    DECLARE @MontoTotal money
    SELECT @MontoTotal = SUM(c.Total)
    FROM compra c
    WHERE c.idProveedor = @idProveedor
    AND c.Fecha BETWEEN @FechaInicio AND @FechaFin
    RETURN ISNULL(@MontoTotal, 0)
END
---------------------------------------------------------------------------------
--01 función para calcular el sueldo total de un empleado con comisión:

CREATE FUNCTION fn_CalcularSueldoConComision (
    @idEmpleado int
)
RETURNS decimal(10, 2)
AS
BEGIN
    DECLARE @Sueldo float
    DECLARE @PorcentajeComision float= 0.05
    DECLARE @SueldoConComision float

    SELECT @Sueldo = e.Sueldo
    FROM empleado e
    WHERE e.idEmpleado = @idEmpleado

    SET @SueldoConComision = @Sueldo + (@Sueldo * @PorcentajeComision)
    RETURN @SueldoConComision
END
---------------------------------------------------------------------------------
/* RF2: Control de medicamentos
--01 Calcular días restantes que le quedan a un producto antes de su caducidad
CREATE FUNCTION fn_DiasRestantesCaducidad
(@idProducto int)
RETURNS int
AS
BEGIN
    DECLARE @DiasRestantes int

    SELECT @DiasRestantes = DATEDIFF(DAY, GETDATE(), FechaVencimiento)
    FROM producto
    WHERE idProducto = @idProducto

    RETURN ISNULL(@DiasRestantes, 0)
END
---------------------------------------------------------------------------------
-- RF3: Registro de clientes

--01	Cantidad de compras de clientes

CREATE FUNCTION fn_Cantidad_ComprasCliente(
@idCliente int
)
RETURNS int
AS
BEGIN
    DECLARE @TotalCompras int

    SELECT @TotalCompras = COUNT(*) 
    FROM ventas
    WHERE idCliente = @idCliente

    RETURN @TotalCompras
END
--RF4: Administración de empleados
--01 RETORNA LA VENTA DE UN EMPLEADO POR SU ID Y EL ID DE LA VENTA
CREATE FUNCTION FN_ObtenerVentaEmpleado
(@idEmpleado INT,@idVenta INT)
RETURNS TABLE
AS
RETURN
(   SELECT v.IdVenta, v.Serie, v.Numero, v.Fecha, v.VentaTotal, v.Descuento, v.SubTotal, v.Igv
    FROM ventas v
    WHERE v.idEmpleado=@idEmpleado AND v.IdVenta=@idVenta)

--02 RETORNA EL TOTAL DE LAS VENTAS DE TODOS LOS EMPLEADOS ENTRE CIERTAS FECHAS
CREATE FUNCTION FN_ObtenerTotalVentasPorFechas
(@FechaInicio DATE, @FechaFin DATE)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @TotalVentas DECIMAL(10, 2)
    SELECT @TotalVentas=SUM(VentaTotal)
    FROM ventas
    WHERE Fecha BETWEEN @FechaInicio AND @FechaFin
    RETURN @TotalVentas
END
---------------------------------------------------------------------------------



/* RF5: Gestión de ventas y compras (04)

--01 funcion de la busquedas de productos en el almacen*/

CREATE FUNCTION BuscarProductoFuncion (
    @criterio VARCHAR(30),
    @Prod VARCHAR(20)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        p.idProducto, pr.Descripcion AS presentacion, p.Nombre, p.Concentracion, p.Stock, p.Costo, 
        p.Precio_Venta, p.FechaVencimiento, p.RegistroSanitario, l.Nombre AS laboratorio, p.Estado
    FROM
        producto p INNER JOIN presentacion pr 
        ON p.idPresentacion = pr.idPresentacion INNER JOIN laboratorio l 
        ON p.idLaboratorio = l.idLaboratorio
    WHERE @criterio = 'Buscar' AND p.Nombre LIKE CONCAT('%', @Prod, '%')
)
---------------------------------------------------------------------------------
--02 una funcion de las ventas realizadas por un empleado en un rango de fechas.

CREATE FUNCTION fn_VentasPorEmpleado
(@idEmpledo INT, @FechaInicio DATE, @FechaFin DATE)
RETURNS TABLE
AS
RETURN (
    SELECT Fecha, Total
    FROM Ventas
    WHERE idEmpleado = @idEmpleado AND 
	Fecha BETWEEN @FechaInicio AND @FechaFin)
---------------------------------------------------------------------------------
-03. el promedio de ventas diarias de un empleado en un mes específico. */
CREATE FUNCTION fn_PromedioVentasDiarias
(@idEmpleado INT, @Mes INT, @Año INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Promedio DECIMAL(10,2)
    
    SELECT @Promedio = AVG(VentaTotal)
    FROM ventas
    WHERE idEmpleado = @idEmpleado AND MONTH(Fecha) = @Mes AND YEAR(Fecha) = @Año
    GROUP BY DAY(Fecha)
    RETURN @Promedio
END
--04	obtiene el detalle de una compra específica por el ID de compra y producto
CREATE FUNCTION fn_ObtenerDetalleCompra
(@idCompra INT, @idProducto INT)
RETURNS TABLE
AS
RETURN
(   SELECT dc.IdCompra, dc.idProducto, dc.Cantidad, dc.Costo, dc.Importe
    FROM detallecompra dc
    WHERE dc.IdCompra = @idCompra AND dc.idProducto = @idProducto )
---------------------------------------------------------------------------------
--RF6: Detalles de Ventas

--01. una funcion del total de ventas de un producto específico. */
CREATE FUNCTION fn_TotalVentasProducto(@idProducto INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @TotalVentas DECIMAL(10,2)
    SELECT @TotalVentas = SUM(Cantidad * Precio)
    FROM DetallesVenta
    WHERE idProducto = @idProducto
    RETURN @TotalVentas
END
---------------------------------------------------------------------------------
--RF10: Seguimiento de Ventas
--01 función para obtener el promedio de ventas por empleado en un periodo determinado:

CREATE FUNCTION fn_PromedioVentasPorEmpleado (
    @idEmpleado int,
    @FechaInicio date,
    @FechaFin date
)
RETURNS float
AS
BEGIN
    DECLARE @TotalVentas decimal(10, 2);
    DECLARE @Dias int;

    SELECT @TotalVentas = SUM(v.VentaTotal)
    FROM ventas v
    WHERE v.idEmpleado = @idEmpleado
    AND v.Fecha >= @FechaInicio AND v.Fecha <= @FechaFin

    SELECT @Dias = DATEDIFF(day, @FechaInicio, @FechaFin)

    RETURN @TotalVentas / @Dias
END
---------------------------------------------------------------------------------
--02  función que calcula el total de ventas de un empleado en función de su ID :

CREATE FUNCTION fn_TotalVentasEmpleado (@idEmpleado int)
RETURNS float
AS
BEGIN
    DECLARE @TotalVentas float
    SELECT @TotalVentas = SUM(v.VentaTotal)
    FROM ventas v
    WHERE v.idEmpleado = @idEmpleado
    RETURN @TotalVentas
END
--03	Tipo de comprobante con más ventas asociadas

CREATE FUNCTION fn_CantidadVentasPorTipoComprobante(
@idTipoComprobante int
)
RETURNS INT
AS
BEGIN
    DECLARE @NumVentas INT

    SELECT @NumVentas = COUNT(*) 
    FROM ventas
    WHERE idcomprobante = @idTipoComprobante;

    RETURN @NumVentas
END
---------------------------------------------------------------------------------
--RF11: Alertas de Caducidad
--01 Se debe enviar una notificación a los empleados encargados para que tomen 
medidas */

CREATE FUNCTION AlertasCaducidadMedicamentos()
RETURNS TABLE
AS
RETURN
(SELECT 'Productos con Fecha de Vencimiento Próxima a Vencer' AS Mensaje,
           p.idProducto, p.Nombre, p.FechaVencimiento
    FROM producto p
    WHERE p.Estado = 'Disponible' AND p.FechaVencimiento <= DATEADD(DAY, 30, GETDATE()))
---------------------------------------------------------------------------------
--RF13: Gestión de Laboratorios

--01 Mostrar laboratorio con mayor cantidad de ventas
CREATE FUNCTION FN_LaboratorioMasConsumido()
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @Laboratorio VARCHAR(50)
    SELECT TOP 1 @Laboratorio = l.Nombre
    FROM laboratorio l
    INNER JOIN producto p ON l.idLaboratorio = p.idLaboratorio
    INNER JOIN detalleventa dv ON p.idProducto = dv.idProducto
    GROUP BY l.Nombre
    ORDER BY SUM(dv.Cantidad) DESC
    RETURN @Laboratorio
END
---------------------------------------------------------------
