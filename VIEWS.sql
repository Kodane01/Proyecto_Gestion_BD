-- VISTAS

--RF1: Gestión de Proveedores
--01 Esta vista permite la información de compras de manera simplificada y seguras.

CREATE VIEW Vista_Compras AS
SELECT c.idCompra, c.Numero, c.Fecha, p.Nombres AS Proveedor, c.SubTotal, c.Total
FROM compra c
INNER JOIN proveedor p ON c.idProveedor = p.idProveedor
---------------------------------------------------------------------------------
--02 vista del historial de compras por proveedor
CREATE VIEW HistorialComprasProveedor AS
SELECT 
    p.Nombre AS NombreProveedor,
    c.Fecha,
    prod.Nombre,
    dc.Cantidad,
    prod.Costo,
    (dc.Cantidad * prod.PrecioCompra) AS TotalCompra
FROM 
    Proveedores p
INNER JOIN 
    Compras c ON p.idProveedor = c.idProveedor
INNER JOIN 
    DetalleCompra dc ON c.idCompra = dc.idCompra
INNER JOIN 
    Productos prod ON dc.idProducto = prod.idProducto
ORDER BY 
    p.Nombre, 
    c.FechaCompra
---------------------------------------------------------------------------------
--03 vista del proveedor*/
CREATE VIEW Vista_Proveedor
AS
SELECT idProveedor,Nombre, Ruc AS RUC_EMPRESA ,Dni,Email,Direccion,Telefono 
FROM Proveedor
---------------------------------------------------------------------------------
--RF02: Control de medicamentos

-- 3)	Vista para mostrar el resumen de ventas mensuales para cada producto 

CREATE VIEW w_VistaVentasMensuales AS
SELECT	P.Descripcion AS Producto, DATENAME(MONTH, V.Fecha) AS Mes, YEAR(V.Fecha) AS Año, 
		SUM(DV.Cantidad) AS CantidadVendida
FROM producto P
JOIN detalleventa DV ON P.idProducto = DV.idProducto
JOIN ventas V ON DV.IdVenta = V.IdVenta
GROUP BY P.Descripcion, DATENAME
---------------------------------------------------------------------------------
--	RF3: Registro de Clientes

--01	Genere una vista que combine la información del cliente con su historial de compras,
--mostrando el nombre del cliente, la fecha de compra y el monto total gastado en cada compra.

CREATE VIEW w_HistorialCompras_Cliente as
SELECT TOP 100 PERCENT 
		C.idCliente, C.Dni, C.Nombres + ' ' + C.Apellidos as [Nombres Completos], 
		V.Fecha, SUM(V.TOTAL) AS [Compras Realizadas]
FROM CLIENTE C
JOIN VENTAS V ON V.idCliente = C.idCliente
GROUP BY C.idCliente, C.Dni, C.Nombres, C.Apellidos, V.FECHA
ORDER BY C.idCliente ASC

---------------------------------------------------------------------------------
--RF4: Administración de empleados

--01 VISTAS DE TODAS LAS VENTAS REALIZADAS DE UN EMPLEADO EN UN RANGO DE FECHAS
CREATE VIEW V_VentasPorEmpleadoEntreFechas
AS
SELECT v.IdVenta, v.Serie, v.Numero, v.Fecha, v.VentaTotal, v.Descuento, v.SubTotal, v.Igv
FROM ventas v
JOIN empleado e ON v.idEmpleado=e.idEmpleado
WHERE v.Fecha BETWEEN @FechaInicio AND @FechaFin
---------------------------------------------------------------------------------
--02 VISTA QUE MUESTRA LOS EMPLEADOS CON MÁS VENTAS Y EL TOTAL EN UN RANGO DE FECHAS
CREATE VIEW V_EmpleadosConMasVentasYTotalEntreFechas
AS
SELECT e.idEmpleado, e.Nombres, e.Apellidos, COUNT(v.IdVenta) TotalVentas, SUM(v.VentaTotal) TotalVentasMonto
FROM empleado e
LEFT JOIN ventas v ON e.idEmpleado=v.idEmpleado
WHERE v.Fecha BETWEEN @FechaInicio AND @FechaFin
GROUP BY e.idEmpleado, e.Nombres, e.Apellidos
ORDER BY TotalVentas DESC
---------------------------------------------------------------------------------
-- RF5: Gestión de ventas y compras (04)

--01	Vista para mostrar la compra de productos 

CREATE VIEW w_ProveedorProductosSuministrados AS
SELECT C.idCompra, PD.Descripcion, PR.IdProveedor, PR.Nombres Proveedor, SUM(C.TOTAL) [Total Compra]
FROM compra C
JOIN proveedor PR ON PR.idProveedor = C.idProveedor
JOIN detallecompra DC ON DC.idCompra = C.idCompra
JOIN producto PD ON PD.idProducto = DC.idProducto
GROUP BY C.idCompra, PR.IdProveedor, PR.Nombres, PD.Descripcion

SELECT * FROM w_ProveedorProductosSuministrados
--02 Te permite acceder a la información de las ventas, incluyendo el nombre completo del cliente asociado a cada venta
CREATE VIEW Vista_Ventas AS
SELECT v.IdVenta, v.Serie, v.Numero, v.Fecha, c.Nombres + ' ' + c.Apellidos AS Cliente, v.Total
FROM ventas v
INNER JOIN cliente c ON v.idCliente = c.idCliente
---------------------------------------------------------------------------------
--RF6: Detalles de ventas 

--01 Mes más bajo más alto de ventas de cada producto
CREATE VIEW Vista_MesBajoAltoVentasPorProducto
AS
SELECT
    p.idProducto,
    p.Descripcion AS Producto,
    MIN(FORMAT(v.Fecha, 'MMMM yyyy')) AS MesMasBajo,
    MAX(FORMAT(v.Fecha, 'MMMM yyyy')) AS MesMasAlto
FROM
    producto p
LEFT JOIN detalleventa dv ON p.idProducto = dv.idProducto
LEFT JOIN ventas v ON dv.IdVenta = v.IdVenta
GROUP BY p.idProducto, p.Descripcion
---------------------------------------------------------------------------------
--02 Vista que muestra detalles de ventas con productos
CREATE VIEW Vista_DetallesVentasConProductos
AS
SELECT
    v.IdVenta,
    v.Serie AS SerieVenta,
    v.Numero AS NumeroVenta,
    v.Fecha AS FechaVenta,
    c.Nombres AS NombreCliente,
    c.Apellidos AS ApellidoCliente,
    p.Descripcion AS NombreProducto,
    dv.Cantidad AS CantidadVendida,
    p.Precio_Venta AS PrecioUnitario,
    dv.Importe AS ImporteTotal
FROM
    ventas v
INNER JOIN cliente c ON v.idCliente = c.idCliente
INNER JOIN detalleventa dv ON v.IdVenta = dv.IdVenta
INNER JOIN producto p ON dv.idProducto = p.idProducto
---------------------------------------------------------------------------------
--RF10: Seguimiento de Ventas

--01	Vista para mostrar las ventas totales para cada venta realizada por un empleado específico.

CREATE VIEW w_VentasTotales_Empleado AS
SELECT TOP 100 PERCENT	
		E.idEmpleado, E.Dni, E.Nombres, E.Apellidos, E.Cargo, 
		COUNT(V.IdVenta) [Cantidad Ventas], SUM(V.Total)  AS [Ventas Totales]
FROM Empleado E
LEFT JOIN Ventas V ON V.IdEmpleado = E.IdEmpleado
GROUP BY E.idEmpleado, E.Dni, E.Nombres, E.Apellidos, E.Cargo 
ORDER BY idEmpleado ASC
---------------------------------------------------------------------------------
--02 vista para tener un reporte de las ventas anuales por empleado
CREATE VIEW ReporteVentasAnualesPorEmpleado AS
SELECT 
    e.idEmpleado,
    e.Nombre AS NombreEmpleado,
    YEAR(v.Fecha) AS Año,
    SUM(d.Cantidad * v.Precio) AS TotalVendido
FROM 
    Ventas v
INNER JOIN 
    Empleado e ON v.idEmpleado = e.idEmpleado
INNER JOIN 
    detalleVenta d ON v.idVenta = d.idVenta
GROUP BY 
    e.idEmpleado, 
    e.Nombre, 
    YEAR(v.Fecha)
ORDER BY 
    Año DESC, 
    TotalVendido DESC;
---------------------------------------------------------------------------------
--RF11: Alertas de Caducidad

--Esta vista te devolvería todos los productos activos.
CREATE VIEW Vista_Productos AS
SELECT idProducto, Descripcion, Precio_Venta
FROM producto
WHERE Estado = 'Activo'
---------------------------------------------------------------------------------
--RF13: Gestión de Laboratorios

--01 Vista que muestra información de laboratorios
CREATE VIEW Vista_InformacionLaboratorios
AS
SELECT
    idLaboratorio,
    Nombre AS NombreLaboratorio,
    Direccion AS DireccionLaboratorio,
    Telefono AS TelefonoLaboratorio
FROM laboratorio
