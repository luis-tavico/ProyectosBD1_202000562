-- INSERCION DE DATOS CLIENTES Y CUENTAS.
-- REGISTROS CLIENTES
CALL registrarCliente(202401, 'Cliente','UnoNacional','50210001000','clienteuno@calificacion.com.gt','userclienteuno','ClIeNtE1202401','1');
CALL registrarCliente(202402, 'Cliente','DosExtranjero','50820002000','cliente2ext@calificacion.com.gt','userclienteextranjero','ExtraNjer0Pass@word','2');
CALL registrarCliente(202403, 'Cliente','TresPyme','50230223480-35503080-32803060-50235253030','clientetres@pyme.com.gt','userclientepyme','PyMeeMpresa@pass','3' );
CALL registrarCliente(202404, 'Cliente','CuatroEmpresaSC','50240004000-40014002','EmpresaSC@noespyme.com.gt','userclienteEmpresaSC','SCeMpreEsa@2024','4');
-- VALIDACIONES DE CLIENTES
CALL registrarCliente(202405, 'Cliente','numero5','50240004000-40014002','noregistrar@noespyme.com.gt','userclienteEmpresaSC','SCeMpreEsa@2024','5');
CALL registrarCliente(202405, 'Cliente','cinco','50240004000-40014002','noregistrar@noespyme.com.gt','userclienteEmpresaSC','SCeMpreEsa@2024','5'); 
CALL registrarCliente(20240t, 'Cliente','cinco','50240004000-40014002','noregistrar@noespyme.com.gt','userclienteEmpresaSC','SCeMpreEsa@2024','5'); 

-- REGISTROS TIPO CLIENTES
CALL registrarTipoCliente(5, 'ClienteExtra', 'Cliente Extraordinario');
-- VALIDACIONES DE TIPO CLIENTES
CALL registrarTipoCliente(8, 'ClienteExtraDos', 'Cliente Extraordinario 2'); -- error numeros
CALL registrarTipoCliente(5, 'ClienteExtra', 'Cliente Extraordinario'); -- tipo de cliente ya existe

-- REGISTROS CUENTA
--            idcuenta, montoapertura,*saldo, descripcion,                   fechaapertura,             otrosdetalles,idtipocuenta,idcliente
CALL registrarCuenta(20250001,2800.00,2800.00,'Apertura de cuenta cheques con Q2800.00','03/05/2024 13:00:00','esta apertura tiene fecha',1,202401); -- cuenta cheques
CALL registrarCuenta(20250030,1800.00,1800.00,'Apertura de cuenta cheques con Q1800.00','03/05/2024 13:00:00','esta apertura tiene fecha',1,202401); -- cuenta cheques
CALL registrarCuenta(20250002,800.00,800.00,'Apertura de cuenta ahorro con Q800.00','03/06/2024 14:00:00','esta apertura tiene fecha',2,202401); -- cuenta ahorro
CALL registrarCuenta(20250003,4900.00,4900.00,'Apertura de cuenta plus con Q4900.00','','',3,202402); -- ahorro plus
CALL registrarCuenta(20250004,100.00,100.00,'Apertura de cuenta pequeña con Q100.00','04/05/2024 09:00:00','esta apertura tiene fecha',4,202403); -- cuenta pequeña
CALL registrarCuenta(20250005,4200.00,4200.00,'Apertura de cuenta nomina con Q4200.00','','esta apertura no tiene fecha',5,202404); -- cuenta nomina
CALL registrarCuenta(20250006,1100.00,1100.00,'Apertura de cuenta inversion con Q1100.00','','esta apertura no tiene fecha',6,202404); -- cuenta inversión
-- VALIDACIONES DE CUENTA
CALL registrarCuenta(20250007,2800.00,2800.10,'Apertura de cuenta cheques con Q2800.00','01/04/2024 07:00:00','esta apertura tiene fecha',1,202401); -- error saldo
CALL registrarCuenta(20250007,1100.00,1100.00,'Apertura de cuenta inversion con Q1100.00','','esta apertura no tiene fecha',6,202405); -- error cliente no existe
CALL registrarCuenta(20250007,1100.00,1100.00,'Apertura de cuenta inversion con Q1100.00','','no existe tipo de cuenta',8,202404); -- tipo de cuenta no existe
CALL registrarCuenta(20250005,4200.00,4200.00,'Apertura de cuenta nomina con Q4200.00','','esta apertura no tiene fecha',5,202404); -- cuenta nominas ya existe

-- REGISTRO TIPO CUENTA
CALL registrarTipoCuenta(7,'',''); -- error nombre y descripción vacíos


-- INGRESO TIPO TRANSACCION
--                    id, tipo, costo, descripcion
CALL crearProductoServicio(18, 1, 37.25,'Servicio de Calificacion');
CALL crearProductoServicio(19, 2, 0,'ProductoCalificacion'); 
-- VALIDACIONES DE TIPO DE TRANSACCION
CALL crearProductoServicio(29, 2, 37.25,'Servicio de Calificacion con error'); -- error tipo 2 de producto no debe tener precio
CALL crearProductoServicio(20, 2, -15.25,'ProductoCalificacionMalo'); -- error precio negativo

-- INGRESO COMPRAS
--              id,      fecha,   monto,  otrosdetalles, codProducto/Servicio, idcliente
CALL realizarCompra(503801, '08/01/2024', 40.00, 'compraproductocalificacion', 19, 202401); 
CALL realizarCompra(503802, '09/01/2024', 0, 'compraserviciocalificacion', 18, 202401); 
CALL realizarCompra(503803, '10/02/2024', 0, 'compraserviciotarjeta', 1, 202401); 
CALL realizarCompra(503804, '13/02/2024', 0, 'comprabancapersonal', 4, 202401); 
CALL realizarCompra(503805, '15/03/2024', 500.00, 'pagoluzmarzo', 11, 202401); 
CALL realizarCompra(503806, '15/04/2024', 550.00, 'pagoluzabril', 11, 202401); 
CALL realizarCompra(503807, '15/05/2024', 420.80, 'pagoluzmayo', 11, 202401); 
CALL realizarCompra(503808, '08/01/2024', 50.35, 'pagoagua', 12, 202402); 
CALL realizarCompra(503809, '09/02/2024', 150.35, 'pagoagua', 12, 202402); 
CALL realizarCompra(503810, '10/03/2024', 44.35, 'pagoagua', 12, 202402); 
CALL realizarCompra(503811, '08/01/2024', 0, 'segurodevidaplus', 6, 202403); 
CALL realizarCompra(503812, '09/02/2024', 0, 'segurodelcarro', 7, 202403); 
CALL realizarCompra(503813, '01/01/2020', 1150.35, 'matriculausac', 13, 202404); 
CALL realizarCompra(503814, '15/03/2024', 500.50, 'pagocursovacas', 14, 202404); 
-- VALIDACIONES DE COMPRAS
CALL realizarCompra(503814, '15/03/2024', 500.50, 'pagocursovacas', 14, 202404); -- compra ya existe
CALL realizarCompra(505050, '15/03/2024', 500.50, 'pagocursovacas', 14, 123456987); -- error cliente no existe

-- INGRESO DEPOSITOS
--              id,      fecha,     monto,  otrosdetalles, idcliente
CALL realizarDeposito(329701, '01/01/2024', 200.00, 'deposito a 202401 de 202402', 202402);
CALL realizarDeposito(329702, '02/04/2024', 300.00, 'deposito a 202403 de 202402', 202402);
CALL realizarDeposito(329703, '01/01/2024', 1000.00, 'deposito a 202404 de 202402', 202402);
CALL realizarDeposito(329704, '28/02/2024', 200.00, 'deposito a 202402 de 202401', 202401);
-- VALIDACIONES DE DEPOSITOS
CALL realizarDeposito(329704, '28/02/2024', 200.00, 'deposito a 202402 de 202401', 202401); -- deposito ya existe
CALL realizarDeposito(329705, '28/02/2024', 200.00, 'deposito a 202402 de 202401', 123456789); -- error cliente no existe
CALL realizarDeposito(329797, '28/02/2024', 0.00, 'deposito a 202402 de 202401', 202401); -- error monto 0

-- INGRESO RETIROS
--              id,      fecha,     monto,  otrosdetalles, idcliente
CALL realizarDebito(429701, '10/05/2024', 600.00, 'retiro de dinero de cliente UnoNacional', 202401);
CALL realizarDebito(429702, '10/04/2024', 100.55, 'retiro de dinero DosExtranjero', 202402);
CALL realizarDebito(429703, '10/03/2024', 50.45, 'retiro de dinero TresPyme', 202403);
CALL realizarDebito(429704, '10/02/2024', 200.85, 'retiro de dinero CuatroEmpresaSC', 202404);
-- VALIDACIONES DE RETIROS
CALL realizarDebito(429705, '10/02/2024', 200.85, 'retiro de dinero CuatroEmpresaSC', 202404); -- retiro ya existe
CALL realizarDebito(429705, '10/02/2024', 200.85, 'retiro de dinero CuatroEmpresaSC', 123456789); -- error cliente no existe
CALL realizarDebito(429705, '10/02/2024', 0.00, 'retiro de dinero CuatroEmpresaSC', 202404); -- error monto 0

-- REGISTRO TRANSACCIONES
--                id,  fecha,  otrosdetalles,     id_tipo_transaccion, idcompra/deposito/debito, nocuenta
CALL asignarTransaccion(1, '08/02/2024','compraproductocalificacion',1, 503801, 20250001); -- transacción de compra
CALL asignarTransaccion(2, '09/01/2024','compraserviciocalificacion',1, 503802, 20250001); -- transacción de compra
CALL asignarTransaccion(3, '10/02/2024','compraserviciotarjeta',1, 503803, 20250002); -- transacción de compra
CALL asignarTransaccion(4, '13/02/2024','comprabancapersonal',1, 503804, 20250002); -- transacción de compra
CALL asignarTransaccion(5, '15/03/2024','pagoluzmarzo',1, 503805, 20250001); -- transacción de compra
CALL asignarTransaccion(6, '15/04/2024','pagoluzabril',1, 503806, 20250002); -- transacción de compra
CALL asignarTransaccion(7, '15/05/2024','pagoluzmayo',1, 503807, 20250002); -- transacción de compra
CALL asignarTransaccion(8, '10/05/2024','debito',3, 429701, 20250001); -- transacción debito
CALL asignarTransaccion(9, '10/04/2024','debito',3, 429702, 20250003); -- transacción debito
CALL asignarTransaccion(10, '10/03/2024','debito',3, 429703, 20250004); -- transacción debito
CALL asignarTransaccion(11, '10/02/2024','debito',3, 429704, 20250006); -- transacción debito
-- VALIDACIONES DE TRANSACCIONES
CALL asignarTransaccion(8, '10/02/2024','debito',3, 429704, 20250006); -- transacción ya existe

CALL registrarTipoTransaccion(4, '', ''); -- error nombre y descripción vacíos