CALL consultarSaldoCliente(20250001); -- Q1289.20
CALL consultarSaldoCliente(20250002); -- Q4654.95
CALL consultarSaldoCliente(20250003); 
CALL consultarSaldoCliente(20250004);
CALL consultarSaldoCliente(20250006);

CALL consultarCliente(202401);
CALL consultarCliente(202402);
CALL consultarCliente(202403);
CALL consultarCliente(202404);

CALL consultarMovsCliente(202401);
CALL consultarMovsCliente(202402);
CALL consultarMovsCliente(202403);
CALL consultarMovsCliente(202404);

CALL consultarTipoCuentas(1);
CALL consultarTipoCuentas(5);

CALL consultarMovsGenFech('01/01/2024','08/08/2024');

CALL consultarMovsFechClien(202401,'01/01/2020','12/12/2024');
CALL consultarMovsFechClien(202402,'01/01/2020','12/12/2024');
CALL consultarMovsFechClien(202403,'01/01/2020','12/12/2024');
CALL consultarMovsFechClien(202404,'01/01/2020','12/12/2024');

CALL consultarProductoServicio();

SELECT * FROM Historial;