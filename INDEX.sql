NO FUNCIONAL (17)
--RNF1: Rendimiento y Tiempo de Respuesta 
--01 la creación del índice "idx_Descripcion_Producto" en la columna "Descripcion" de la tabla "producto" tiene como objetivo mejorar la eficiencia de las consultas que buscan productos por su descripción.
CREATE NONCLUSTERED INDEX idx_Descripcion_Producto
ON producto (Descripcion)


--02 La creación del índice "idx_Fecha_IdEmpleado_Ventas" en las columnas "Fecha" e "idEmpleado" de la tabla "ventas" 
--tiene como objetivo mejorar la eficiencia de las consultas que buscan ventas por estas dos variables. 
CREATE NONCLUSTERED INDEX idx_Fecha_IdEmpleado_Ventas
ON ventas (Fecha, idEmpleado)


--03 Esto significa que la tabla "detallecompra" estará organizada en disco de acuerdo con el orden del índice,
--lo cual puede afectar el rendimiento de las operaciones de inserción y actualización,
--ya que los datos deben reorganizarse para mantener el orden del índice. 
CREATE CLUSTERED INDEX idx_idProducto_DetalleCompra
ON detallecompra (idProducto)

--04 no agrupado para la columna de fecha de vencimiento  */
CREATE NONCLUSTERED INDEX idx_AlertasCaducidadMedicamentos
ON producto (FechaVencimiento);

--05 permitirá que las consultas que buscan empleados por nombre y cargo al mismo tiempo*/
CREATE INDEX idx_NombreCargo
ON empleado (Nombres, Cargo);

--06 no agrupado para la columna de cantidad,costo, idventa,idProducto  */
CREATE NONCLUSTERED INDEX idx_DetalleVenta
ON detalleventa (cantidad, costo, idProducto, IdVenta);

--07 no agrupado para la columna de Apellidos de Usuario*/
CREATE NONCLUSTERED INDEX idx_Apellidos_Usuario
ON usuario (apellidos);

--08 no agrupado de cantidad y costos para detalleventa*/
CREATE NONCLUSTERED INDEX idx_Cantidad_Costo_DetalleVenta 
ON detalleventa (cantidad, costo);

--09 agrupado de la tabla empleados en la columna idEmpleado*/
CREATE CLUSTERED INDEX idx_idEmpleado_Empleado
ON empleado (idEmpleado);

--10 Indice no agrupado
CREATE NONCLUSTERED INDEX IX_Cliente_Nombre
ON cliente (Nombre);

--11 Indice no agrupado
CREATE NONCLUSTERED INDEX IX_Producto_Costo
ON producto (Costo);

--12 Indice agrupado
CREATE CLUSTERED INDEX IX_Proveedor_idProveedor
ON proveedor(idProveedor);

--13 INDICE  CLUSTERED CON LA EL CAMPO SUELDO DE EMPLEADOS
CREATE CLUSTERED INDEX IDX_SUELDO
ON empleados(Sueldo DESC)


--14POR LA FECHA DE INICIO DE ESTAR LABURANDO EN LA EMPRESA
CREATE NONCLUSTERED INDEX IDX_FechaLaboral
ON empleados(FechaLaboral)

--15 Índice agrupado en la tabla producto para la columna idLaboratorio:
CREATE CLUSTERED INDEX idx_idLaboratorio_Producto
ON producto (idLaboratorio)

--16 Índice no agrupado de stock y decripcion para productos:
CREATE NONCLUSTERED INDEX IX_Stock_Descripcion_Producto
ON producto (Stock, Descripcion)


--17 Índice no agrupado para las columnas Nombres y Apellidos de Usuario
CREATE NONCLUSTERED INDEX idx_Nombres_Apellidos_Usuario
ON usuario (Nombres, Apellidos)
 
