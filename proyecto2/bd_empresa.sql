DROP DATABASE IF EXISTS empresa;

CREATE DATABASE empresa;

USE empresa;

CREATE TABLE TipoCliente (
    idTipoCliente INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(255),
    descripcion VARCHAR(255)
);

CREATE TABLE Cliente (
    idCliente INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(255) NOT NULL,
    apellidos VARCHAR(255) NOT NULL,
    correo VARCHAR(255) NOT NULL,
    usuario VARCHAR(255) UNIQUE NOT NULL,
    contraseña VARCHAR(255) NOT NULL,
    fechaCreacion DATE,
    tipoCliente_id INT NOT NULL,
    FOREIGN KEY (tipoCliente_id) REFERENCES TipoCliente(idTipoCliente)
);

CREATE TABLE Telefono (
    idTelefono INT PRIMARY KEY AUTO_INCREMENT,
    telefono VARCHAR(255) NOT NULL,
    cliente_id INT NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES Cliente(idCliente)
);

CREATE TABLE TipoCuenta (
    codigo INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(255) NOT NULL,
    descripcion VARCHAR(255) NOT NULL
);

CREATE TABLE Cuenta (
    idCuenta BIGINT PRIMARY KEY AUTO_INCREMENT,
    montoApertura DECIMAL(12,2) NOT NULL,
    saldoCuenta DECIMAL(12,2) NOT NULL,
    descripcion VARCHAR(255),
    fechaApertura DATETIME,
    otrosDetalles VARCHAR(255),
    tipoCuenta_id INT NOT NULL,
    cliente_id INT NOT NULL,
    FOREIGN KEY (tipoCuenta_id) REFERENCES TipoCuenta(codigo),
    FOREIGN KEY (cliente_id) REFERENCES Cliente(idCliente)
);

CREATE TABLE ProductoServicio (
    codigo INT PRIMARY KEY AUTO_INCREMENT,
    tipo INT NOT NULL,
    costo DECIMAL(12,2) NOT NULL,
    descripcion VARCHAR(255) NOT NULL
);

CREATE TABLE Compra (
    idCompra INT PRIMARY KEY AUTO_INCREMENT,
    fecha DATE NOT NULL,
    importeCompra DECIMAL(12,2), -- monto
    otrosDetalles VARCHAR(255),
    productoServicio_id INT NOT NULL,
    cliente_id INT NOT NULL,
    FOREIGN KEY (productoServicio_id) REFERENCES ProductoServicio(codigo),
    FOREIGN KEY (cliente_id) REFERENCES Cliente(idCliente)
);

CREATE TABLE Deposito (
    idDeposito INT PRIMARY KEY AUTO_INCREMENT,
    fecha DATE NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    otrosDetalles VARCHAR(255),
    cliente_id INT NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES Cliente(idCliente)
);

CREATE TABLE Debito (
    idDebito INT PRIMARY KEY AUTO_INCREMENT,
    fecha DATE NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    otrosDetalles VARCHAR(255),
    cliente_id INT NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES Cliente(idCliente)
);

CREATE TABLE TipoTransaccion (
    idTipoTransaccion INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(255) NOT NULL,
    descripcion VARCHAR(255) NOT NULL
);

CREATE TABLE Transaccion (
    idTransaccion INT PRIMARY KEY AUTO_INCREMENT,
    fecha DATE NOT NULL,
    otrosDetalles VARCHAR(255),
    tipoTransaccion_id INT NOT NULL,   
    idGestion INT NOT NULL,
    cuenta_id BIGINT NOT NULL,
    FOREIGN KEY (tipoTransaccion_id) REFERENCES TipoTransaccion(idTipoTransaccion),
    FOREIGN KEY (cuenta_id) REFERENCES Cuenta(idCuenta)
);

CREATE TABLE Historial (
    idHistorial INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATETIME,
    descripcion VARCHAR(255),
    tipo ENUM('INSERT', 'UPDATE', 'DELETE')
);

/* ====================================================PROCEDIMIENTOS ALMACENADOS==================================================== */
/* ================================================================================================================================== */
/* ======================================================REGISTRAR TIPO CLIENTE====================================================== */
DELIMITER //

CREATE PROCEDURE registrarTipoCliente (
    IN p_idTipoCliente INT,
    IN p_nombre VARCHAR(255),
    IN p_descripcion VARCHAR(255)
)
BEGIN
    -- Verificar si el tipod de cliente ya existe
    IF EXISTS (SELECT 1 FROM TipoCliente WHERE idTipoCliente = p_idTipoCliente) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El tipo de cliente ya existe.';
    END IF;
    
	-- Validar la descripcion usando la funcion
    IF NOT validarLetras(p_descripcion) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La descripcion solo puede contener letras.';
    END IF;
    
    -- Insertar el tipo de cliente en la tabla
    INSERT INTO TipoCliente(idTipoCliente, nombre, descripcion)
    VALUES (p_idTipoCliente, p_nombre, p_descripcion);
    
    SELECT 'Tipo de cliente registrado exitosamente.' AS mensaje;
END //

DELIMITER ;

/* =========================================================REGISTRAR CLIENTE========================================================= */
DELIMITER //

CREATE PROCEDURE registrarCliente (
    IN p_idCliente INT,
    IN p_nombre VARCHAR(255),
    IN p_apellidos VARCHAR(255),
    IN p_telefono VARCHAR(255),
    IN p_correo VARCHAR(255),
    IN p_usuario VARCHAR(255),
    IN p_contraseña VARCHAR(255),
    IN p_tipoCliente_id INT
)
BEGIN
    DECLARE existe_usuario INT;
	DECLARE st INT;

    -- Verificar si el cliente ya existe
    IF EXISTS (SELECT 1 FROM Cliente WHERE idCliente = p_idCliente) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El cliente ya existe.';
    END IF;
    
    -- Validar que el usuario no exista
    SELECT COUNT(*) INTO existe_usuario FROM Cliente WHERE usuario = p_usuario;
    IF existe_usuario > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El usuario ya existe. Por favor, elija otro.';
    END IF;
    
    -- Validar que el nombre solo contengan letras
	IF NOT validarLetras(p_nombre) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El nombre solo puede contener letras.';
    END IF;
        
	-- Validar que el apellido solo contengan letras
    IF NOT validarLetras(p_apellidos) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Los apellidos solo pueden contener letras.';
    END IF;

	-- Validar el formato del telefono
	IF NOT validarTelefono(p_telefono) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El formato del telefono no es valido.';
    END IF;
    
    SET p_telefono = obtenerTelefonoSinCodigo(p_telefono);

	IF NOT validarCorreo(p_correo) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El correo electrónico no tiene un formato valido.';
	END IF;

    -- Insertar el cliente en la tabla
    INSERT INTO Cliente(idCliente, nombre, apellidos, correo, usuario, contraseña, fechaCreacion, tipoCliente_id)
    VALUES (p_idCliente, p_nombre, p_apellidos, p_correo, p_usuario, p_contraseña, NOW(), p_tipoCliente_id);
    
    -- Insertar el telefono en la tabla Telefono
    SET st = insertarTelefono(p_telefono, p_idCliente);
    
	SELECT 'Cliente registrado exitosamente.' AS mensaje;
END //

DELIMITER ;

/* =======================================================REGISTRAR TIPO CUENTA======================================================= */
DELIMITER //

CREATE PROCEDURE registrarTipoCuenta (
    IN p_codigo INT,
    IN p_nombre VARCHAR(255),
    IN p_descripcion VARCHAR(255)
)
BEGIN
    -- Verificar si el tipo de cuenta ya existe
    IF EXISTS (SELECT 1 FROM TipoCuenta WHERE codigo = p_codigo) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El tipo de cuenta ya existe.';
    END IF;
    
	-- Verificar si el nombre o la descripcion son cadenas vacias
    IF p_nombre = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El nombre no puede estar vacío.';
    END IF;

    IF p_descripcion = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La descripcion no puede estar vacia.';
    END IF;
    
    -- Insertar el tipo de cuenta en la tabla
    INSERT INTO TipoCuenta(codigo, nombre, descripcion)
    VALUES (p_codigo, p_nombre, p_descripcion);
    
	SELECT 'Tipo de cuenta registrada exitosamente.' AS mensaje;
END //

DELIMITER ;

/* =========================================================REGISTRAR CUENTA========================================================= */
DELIMITER //

CREATE PROCEDURE registrarCuenta (
    IN p_idCuenta BIGINT,
    IN p_monto_apertura DECIMAL(12,2),
    IN p_saldo_cuenta DECIMAL(12,2),
    IN p_descripcion VARCHAR(255),
    IN p_fechaApertura VARCHAR(255),
    IN p_otros_detalles VARCHAR(255),
    IN p_tipo_cuenta_id INT,
    IN p_cliente_id INT
)
BEGIN
	DECLARE p_nuevaFechaApertura DATETIME; 
	DECLARE cliente_existe INT;
    DECLARE tipo_cuenta_existe INT;
    
	-- Verificar si la cuenta ya existe
    IF EXISTS (SELECT 1 FROM Cuenta WHERE idCuenta = p_idCuenta) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La cuenta ya existe.';
    END IF;
    
    -- Validar que el monto de apertura sea positivo
    IF p_monto_apertura <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El monto de apertura debe ser positivo.';
    END IF;

    -- Validar que el saldo de cuenta sea mayor o igual a 0
    IF p_saldo_cuenta < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El saldo de cuenta debe ser mayor o igual a 0.';
    END IF;
    
	-- Validar que el monto_apertura y saldo_cuenta sean iguales
    IF p_monto_apertura != p_saldo_cuenta THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El monto de apertura y el saldo de cuenta deben ser iguales.';
    END IF;

    -- Verificar si el cliente existe
    SELECT COUNT(*) INTO cliente_existe FROM Cliente WHERE idCliente = p_cliente_id;
    IF cliente_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El cliente no existe.';
    END IF;
    
	-- Verificar si el tipo de cuenta existe
    SELECT COUNT(*) INTO tipo_cuenta_existe FROM TipoCuenta WHERE codigo = p_tipo_cuenta_id;
    IF tipo_cuenta_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El tipo de cuenta no existe.';
    END IF;
	
	-- Verificar si el campo fecha esta vacio
	IF p_fechaApertura = '' THEN
        SET p_nuevaFechaApertura = NOW();
    ELSE
		SET p_nuevaFechaApertura = STR_TO_DATE(p_fechaApertura, '%d/%m/%Y %H:%i:%s');
    END IF;

    -- Insertar la cuenta en la tabla
    INSERT INTO Cuenta(idCuenta, montoApertura, saldoCuenta, descripcion, fechaApertura, otrosDetalles, tipoCuenta_id, cliente_id)
    VALUES (p_idCuenta, p_monto_apertura, p_saldo_cuenta, p_descripcion, p_nuevaFechaApertura, p_otros_detalles, p_tipo_cuenta_id, p_cliente_id);
    
    SELECT 'Cuenta registrada exitosamente.' AS mensaje;
END //

DELIMITER ;

/* ======================================================CREAR PRODUCTO/SERVICIO====================================================== */
DELIMITER //

CREATE PROCEDURE crearProductoServicio (
    IN p_codigo INT,
    IN p_tipo INT,
    IN p_costo DECIMAL(12,2),
    IN p_descripcion VARCHAR(100)
)
BEGIN
	-- Verificar si el producto/servicio ya existe
    IF EXISTS (SELECT 1 FROM ProductoServicio WHERE codigo = p_codigo) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El producto/servicio ya existe.';
    END IF;
    
    -- Validar que el tipo sea 1 o 2
     IF p_tipo <> 1 AND p_tipo <> 2 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El valor de tipo no es valido. Debe ser 1 para servicio o 2 para producto.';
    END IF;
    
	-- Validar que el costo sea >= 0
    IF p_costo < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El costo debe ser mayor o igual a 0.';
    END IF;
    
    -- Validar que el costo sea obligatorio para los servicios (tipo = 1)
    IF p_tipo = 1 AND p_costo IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El costo es obligatorio para los servicios.';
    END IF;
    
	-- Validar que el costo sea 0 para los productos (tipo = 2)
    IF p_tipo = 2 AND p_costo != 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El costo debe ser 0 para los productos.';
    END IF;

    -- Insertar el producto o servicio en la tabla
    INSERT INTO ProductoServicio(codigo, tipo, costo, descripcion)
    VALUES (p_codigo, p_tipo, p_costo, p_descripcion);
    
	SELECT 'Producto/Servicio registrado exitosamente.' AS mensaje;
END //

DELIMITER ;

/* ==========================================================REALIZAR COMPRA========================================================== */
DELIMITER //

CREATE PROCEDURE realizarCompra (
    IN p_idCompra INT,
    IN p_fecha VARCHAR(255),
    IN p_importe_compra DECIMAL(12,2),
    IN p_otros_detalles VARCHAR(255),
    IN p_producto_servicio_id INT,
    IN p_cliente_id INT
)
BEGIN
	DECLARE p_nuevaFecha DATE;
    DECLARE tipoProductoServicio INT;
	DECLARE cliente_existe INT;
    
	-- Verificar si la compra ya existe
    IF EXISTS (SELECT 1 FROM Compra WHERE idCompra = p_idCompra) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La compra ya existe.';
    END IF;
    
	-- Verificar si el cliente existe
    SELECT COUNT(*) INTO cliente_existe FROM Cliente WHERE idCliente = p_cliente_id;
    IF cliente_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El cliente no existe.';
    END IF;

	SELECT 
		tipo 
	INTO 
		tipoProductoServicio 
	FROM 
		ProductoServicio 
	WHERE 
		codigo = p_producto_servicio_id;

    -- Validar que el importe de compra sea 0 si se trata de un servicio
    IF tipoProductoServicio = 1 AND p_importe_compra <> 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El monto debe ser igual a 0 ya que es un servicio.';
    END IF;
    
	-- Validar que el importe de compra sea obligatorio si se trata de un producto
    IF tipoProductoServicio = 2 AND p_importe_compra <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El monto debe ser mayor a 0 ya que es un producto.';
    END IF;
    
	-- Verificar si el campo fecha esta vacio
	IF p_fecha = '' THEN
        SET p_nuevaFecha = NOW();
    ELSE
		SET p_nuevaFecha = STR_TO_DATE(p_fecha, '%d/%m/%Y');
    END IF;

    -- Insertar la compra en la tabla
    INSERT INTO Compra(idCompra, fecha, importeCompra, otrosDetalles, productoServicio_id, cliente_id)
    VALUES (p_idCompra, p_nuevaFecha, p_importe_compra, p_otros_detalles, p_producto_servicio_id, p_cliente_id);
    
    SELECT 'Compra registrada exitosamente.' AS mensaje;
END //

DELIMITER ;

/* =========================================================REALIZAR DEPOSITO========================================================= */
DELIMITER //

CREATE PROCEDURE realizarDeposito (
    IN p_idDeposito INT,
    IN p_fecha VARCHAR(255),
    IN p_monto DECIMAL(12,2),
    IN p_otros_detalles VARCHAR(255),
    IN p_cliente_id INT
)
BEGIN
	DECLARE p_nuevaFecha DATE;
	DECLARE cliente_existe INT;
    
	-- Verificar si el deposito ya existe
    IF EXISTS (SELECT 1 FROM Deposito WHERE idDeposito = p_idDeposito) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El deposito ya existe.';
    END IF;
    
	-- Verificar si el cliente existe
    SELECT COUNT(*) INTO cliente_existe FROM Cliente WHERE idCliente = p_cliente_id;
    IF cliente_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El cliente no existe.';
    END IF;

	-- Verificar si el campo fecha esta vacio
	IF p_fecha = '' THEN
        SET p_nuevaFecha = NOW();
    ELSE
		SET p_nuevaFecha = STR_TO_DATE(p_fecha, '%d/%m/%Y');
    END IF;
    
    -- verficar que el monto sea mayor a 0
    IF p_monto <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El monto debe ser mayor a 0.';
    END IF;
    
    -- Insertar el deposito en la tabla
    INSERT INTO Deposito(idDeposito, fecha, monto, otrosDetalles, cliente_id)
    VALUES (p_idDeposito, p_nuevaFecha, p_monto, p_otros_detalles, p_cliente_id);
    
	SELECT 'Deposito registrado exitosamente.' AS mensaje;
END //

DELIMITER ;

/* ==========================================================REALIZAR DEBITO========================================================== */
DELIMITER //

CREATE PROCEDURE realizarDebito (
    IN p_idDebito INT,
    IN p_fecha VARCHAR(255),
    IN p_monto DECIMAL(12,2),
    IN p_otros_detalles VARCHAR(255),
    IN p_cliente_id INT
)
BEGIN
	DECLARE p_nuevaFecha DATE;
	DECLARE cliente_existe INT;
    
	-- Verificar si el debito ya existe
    IF EXISTS (SELECT 1 FROM Debito WHERE idDebito = p_idDebito) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El debito ya existe.';
    END IF;
    
	-- Verificar si el cliente existe
    SELECT COUNT(*) INTO cliente_existe FROM Cliente WHERE idCliente = p_cliente_id;
    IF cliente_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El cliente no existe.';
    END IF;

	-- Verificar si el campo fecha esta vacio
	IF p_fecha = '' THEN
        SET p_nuevaFecha = NOW();
    ELSE
		SET p_nuevaFecha = STR_TO_DATE(p_fecha, '%d/%m/%Y');
    END IF;
    
	-- verficar que el monto sea mayor a 0
    IF p_monto <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El monto debe ser mayor a 0.';
    END IF;
    
    -- Insertar el debito en la tabla
    INSERT INTO Debito(idDebito, fecha, monto, otrosDetalles, cliente_id)
    VALUES (p_idDebito, p_nuevaFecha, p_monto, p_otros_detalles, p_cliente_id);
    
	SELECT 'Debito registrado exitosamente.' AS mensaje;
END //

DELIMITER ;

/* ====================================================REGISTRAR TIPO TRANSACCION==================================================== */
DELIMITER //

CREATE PROCEDURE registrarTipoTransaccion (
    IN p_idTipoTransaccion INT,
    IN p_nombre VARCHAR(255),
    IN p_descripcion VARCHAR(255)
)
BEGIN
	-- Verificar si el tipo de transaccion ya existe
    IF EXISTS (SELECT 1 FROM TipoTransaccion WHERE idTipoTransaccion = p_idTipoTransaccion) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El tipo de transaccion ya existe.';
    END IF;
    
	-- Verificar si el nombre o la descripcion son cadenas vacias
    IF p_nombre = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El nombre no puede estar vacío.';
    END IF;

    IF p_descripcion = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La descripcion no puede estar vacía.';
    END IF;
    
    -- Insertar el tipo de transacción en la tabla
    INSERT INTO TipoTransaccion(idTipoTransaccion, nombre, descripcion)
    VALUES (p_idTipoTransaccion, p_nombre, p_descripcion);
    
	SELECT 'Tipo de transaccion registrada exitosamente.' AS mensaje;
END //

DELIMITER ;

/* ========================================================ASIGNAR TRANSACCION======================================================== */
DELIMITER //

CREATE PROCEDURE asignarTransaccion (
    IN p_idTransaccion INT,
    IN p_fecha VARCHAR(255),
    IN p_otros_detalles VARCHAR(255),
    IN p_tipoTransaccion_id INT,
    IN p_idGestion iNT,
    IN p_cuenta_id BIGINT
)
BEGIN
	DECLARE fecha DATE;
	DECLARE importeCompra DECIMAL(12,2);
	DECLARE monto DECIMAL(12,2);
    DECLARE saldoActual DECIMAL(12,2);
    DECLARE idCliente INT;
    
	-- Verificar si la transaccion ya existe
    IF EXISTS (SELECT 1 FROM Transaccion WHERE idTransaccion = p_idTransaccion) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La transaccion ya existe.';
    END IF;

	-- Verificar si el campo fecha esta vacio
	IF p_fecha = '' THEN
        SET fecha = NOW();
    ELSE
		SET fecha = STR_TO_DATE(p_fecha, '%d/%m/%Y');
    END IF;
    
    -- Verificar el tipo de transaccion
    IF p_tipoTransaccion_id = 1 THEN
        SELECT 
			co.importeCompra, co.cliente_id
		INTO 
			importeCompra, idCliente
        FROM 
            Compra co
		LEFT JOIN 
			Cuenta cu ON co.cliente_id = cu.cliente_id
        WHERE 
            co.idCompra = p_idGestion
            LIMIT 1;      
        
        -- Obtener el saldoCuenta de la tabla Cuenta
		SELECT 
			saldoCuenta 
		INTO 
			saldoActual
		FROM 
			Cuenta
		WHERE 
			idCuenta = p_cuenta_id;

		-- Verificar si el saldo actual es mayor o igual al importe de la compra
		IF saldoActual >= importeCompra THEN
			-- Actualizar el saldo de la cuenta restando el importe de la compra
			UPDATE Cuenta
			SET saldoCuenta = saldoCuenta - importeCompra
			WHERE idCuenta = p_cuenta_id;
		ELSE
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'El saldo de la cuenta es insuficiente para realizar la compra.';
		END IF;
	-- Obtener el monto y el cliente_id del deposito
	ELSEIF p_tipoTransaccion_id = 2 THEN
        SELECT 
            dep.monto, dep.cliente_id
		INTO 
			monto, idCliente
        FROM 
            Deposito dep
		LEFT JOIN 
			Cuenta cu ON dep.cliente_id = cu.cliente_id
        WHERE 
            dep.idDeposito = p_idGestion
            LIMIT 1;
		-- Actualizar el saldo de la cuenta correspondiente sumando el monto del deposito
		UPDATE 
			Cuenta
		SET 
			saldoCuenta = saldoCuenta + monto
		WHERE 
			idCuenta = p_cuenta_id;
	-- Obtener el monto y el cliente_id del debito
    ELSEIF p_tipoTransaccion_id = 3 THEN
        SELECT
			deb.monto, deb.cliente_id
		INTO 
			monto, idCliente
        FROM 
            Debito deb
		LEFT JOIN 
			Cuenta cu ON deb.cliente_id = cu.cliente_id
        WHERE 
            deb.idDebito = p_idGestion
            LIMIT 1;      
        
        -- Obtener el saldoCuenta de la tabla Cuenta
		SELECT 
			saldoCuenta 
		INTO 
			saldoActual
		FROM 
			Cuenta
		WHERE 
			idCuenta = p_cuenta_id
            LIMIT 1;

		-- Verificar si el saldo actual es mayor o igual al importe de la compra
		IF saldoActual >= monto THEN
			-- Actualizar el saldo de la cuenta restando el importe de la compra
			UPDATE Cuenta
			SET saldoCuenta = saldoCuenta - monto
			WHERE idCuenta = p_cuenta_id
            LIMIT 1;
		ELSE
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'El saldo de la cuenta es insuficiente para realizar el debito.';
		END IF;
    ELSE
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El tipo de transaccion no existe.';
    END IF;
    
    -- Insertar la transaccion en la tabla
    INSERT INTO Transaccion(idTransaccion, fecha, otrosDetalles, tipoTransaccion_id, idGestion, cuenta_id)
    VALUES (p_idTransaccion, fecha, p_otros_detalles, p_tipoTransaccion_id, p_idGestion, p_cuenta_id);
    
    SELECT 'Transaccion registrada exitosamente.' AS mensaje;
END //

DELIMITER ;

/* ======================================================CONSULTAR SALDO CLIENTE====================================================== */
DELIMITER //

CREATE PROCEDURE consultarSaldoCliente (
    IN p_numero_cuenta BIGINT
)
BEGIN
    DECLARE cuenta_existe INT;
    DECLARE cliente_id INT;
    DECLARE cliente_nombre VARCHAR(255);
    DECLARE tipo_cliente_nombre VARCHAR(255);
    DECLARE tipo_cuenta_nombre VARCHAR(255);
    DECLARE saldo_cuenta DECIMAL(12,2);
    DECLARE saldo_apertura DECIMAL(12,2);

    -- Verificar si la cuenta existe
    SELECT COUNT(*) INTO cuenta_existe FROM Cuenta WHERE idCuenta = p_numero_cuenta;
    IF cuenta_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La cuenta especificada no existe.';
    END IF;

    -- Obtener la informacion de la cuenta y del cliente
    SELECT 
        c.idCliente,
        CONCAT(c.nombre, ' ', c.apellidos) AS nombre_completo,
        tc.nombre AS tipo_cliente,
        tcu.nombre AS tipo_cuenta,
        cu.saldoCuenta,
        cu.montoApertura
    INTO
        cliente_id,
        cliente_nombre,
        tipo_cliente_nombre,
        tipo_cuenta_nombre,
        saldo_cuenta,
        saldo_apertura
    FROM 
        Cuenta cu
    INNER JOIN
        Cliente c ON cu.cliente_id = c.idCliente
    INNER JOIN
        TipoCliente tc ON c.tipoCliente_id = tc.idTipoCliente
    INNER JOIN
        TipoCuenta tcu ON cu.tipoCuenta_id = tcu.codigo
    WHERE 
        cu.idCuenta = p_numero_cuenta;

    -- Mostrar el resultado
    SELECT 
        cliente_nombre AS 'Nombre Cliente',
        tipo_cliente_nombre AS 'Tipo de cliente',
        tipo_cuenta_nombre AS 'Tipo de cuenta',
        saldo_cuenta AS 'Saldo cuenta',
        saldo_apertura AS 'Saldo apertura';
END //

DELIMITER ;

/* =========================================================CONSULTAR CLIENTE========================================================= */
DELIMITER //

CREATE PROCEDURE consultarCliente (
    IN p_idCliente INT
)
BEGIN
    DECLARE cliente_existe INT;

    -- Verificar si el cliente existe
    SELECT COUNT(*) INTO cliente_existe FROM Cliente WHERE idCliente = p_idCliente;
    IF cliente_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El cliente especificado no existe.';
    END IF;

    -- Consultar la información del cliente
    SELECT 
        c.idCliente,
        CONCAT(c.nombre, ' ', c.apellidos) AS nombre_completo,
        c.fechaCreacion,
        c.usuario,
        c.correo,
        COUNT(cu.idCuenta) AS cantidad_cuentas,
        GROUP_CONCAT(tc.nombre SEPARATOR ', ') AS tipos_cuenta
    FROM 
        Cliente c
    LEFT JOIN 
        Cuenta cu ON c.idCliente = cu.cliente_id
    LEFT JOIN 
        TipoCuenta tc ON cu.tipoCuenta_id = tc.codigo
    WHERE 
        c.idCliente = p_idCliente;
END //

DELIMITER ;

/* =================================================CONSULTAR MOVIMIENTOS DE CLIENTE================================================= */
DELIMITER //

CREATE PROCEDURE consultarMovsCliente (
	IN p_idCliente INT
)
BEGIN
    DECLARE cliente_existe INT;

    -- Verificar si el cliente existe
    SELECT COUNT(*) INTO cliente_existe FROM Cliente WHERE idCliente = p_idCliente;
    IF cliente_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El cliente especificado no existe.';
    END IF;

    -- Consultar los movimientos del cliente
    SELECT 
        t.idTransaccion AS 'Id transacción',
        tt.nombre AS 'Tipo transacción',
        CASE 
            WHEN t.tipoTransaccion_id = 1 THEN c.importeCompra
            WHEN t.tipoTransaccion_id = 2 THEN d.monto
            WHEN t.tipoTransaccion_id = 3 THEN deb.monto
            ELSE NULL
        END AS 'Monto',
        CASE
            WHEN t.tipoTransaccion_id = 1 THEN 'Compra'
            WHEN t.tipoTransaccion_id = 2 THEN 'Depósito'
            WHEN t.tipoTransaccion_id = 3 THEN 'Débito'
            ELSE NULL
        END AS 'Tipo de servicio',
        t.cuenta_id AS 'No. cuenta',
        tc.nombre AS 'Tipo cuenta'
    FROM 
        Transaccion t
    LEFT JOIN 
        TipoTransaccion tt ON t.tipoTransaccion_id = tt.idTipoTransaccion
    LEFT JOIN 
        Compra c ON t.idGestion = c.idCompra AND t.tipoTransaccion_id = 1
    LEFT JOIN 
        Deposito d ON t.idGestion = d.idDeposito AND t.tipoTransaccion_id = 2
    LEFT JOIN 
        Debito deb ON t.idGestion = deb.idDebito AND t.tipoTransaccion_id = 3
    LEFT JOIN 
        Cuenta cu ON t.cuenta_id = cu.idCuenta
    LEFT JOIN 
        TipoCuenta tc ON cu.tipoCuenta_id = tc.codigo
    WHERE 
        cu.cliente_id = p_idCliente;
END //

DELIMITER ;

/* =======================================================CONSULTAR TIPO CUENTA======================================================= */
DELIMITER //

CREATE PROCEDURE consultarTipoCuentas (
    IN p_idTipoCuenta INT
)
BEGIN
    DECLARE tipo_cuenta_existe INT;
    DECLARE tipo_cuenta_codigo INT;
    DECLARE tipo_cuenta_nombre VARCHAR(255);
    DECLARE cantidad_clientes INT;

    -- Verificar si el tipo de cuenta existe
    SELECT COUNT(*) INTO tipo_cuenta_existe FROM TipoCuenta WHERE codigo = p_idTipoCuenta;
    IF tipo_cuenta_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El tipo de cuenta especificado no existe.';
    END IF;

    -- Obtener el código y el nombre del tipo de cuenta
    SELECT codigo, nombre INTO tipo_cuenta_codigo, tipo_cuenta_nombre FROM TipoCuenta WHERE codigo = p_idTipoCuenta;

    -- Obtener la cantidad de clientes que poseen ese tipo de cuenta
    SELECT COUNT(DISTINCT cliente_id) INTO cantidad_clientes FROM Cuenta WHERE tipoCuenta_id = p_idTipoCuenta;

    -- Mostrar el resultado
    SELECT 
        tipo_cuenta_codigo AS 'Código de tipo de cuenta',
        tipo_cuenta_nombre AS 'Nombre cuenta',
        cantidad_clientes AS 'Cantidad de clientes que poseen ese tipo de cuenta';
END //

DELIMITER ;
/* =================================================CONSULTAR MOVIMIENTOS POR FECHA================================================== */
DELIMITER //

CREATE PROCEDURE consultarMovsGenFech (
    IN p_fechaInicio VARCHAR(10),
    IN p_fechaFin VARCHAR(10)
)
BEGIN
    -- Convertir las fechas al formato 'YYYY-MM-DD' para la consulta
    DECLARE fechaInicio DATE;
    DECLARE fechaFin DATE;
    
    SET fechaInicio = STR_TO_DATE(p_fechaInicio, '%d/%m/%Y');
    SET fechaFin = STR_TO_DATE(p_fechaFin, '%d/%m/%Y');

    -- Validar si las fechas son válidas
    IF fechaInicio IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El formato de la fecha de inicio no es válido. Utilice el formato DD/MM/YYYY.';
    END IF;

    IF fechaFin IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El formato de la fecha de fin no es válido. Utilice el formato DD/MM/YYYY.';
    END IF;

    -- Consultar los movimientos dentro del rango de fechas especificado
    SELECT 
        t.idTransaccion AS 'Id transacción',
        tt.nombre AS 'Tipo transacción',
        CASE
            WHEN t.tipoTransaccion_id = 1 THEN 'Compra'
            WHEN t.tipoTransaccion_id = 2 THEN 'Depósito'
            WHEN t.tipoTransaccion_id = 3 THEN 'Débito'
            ELSE NULL
        END AS 'Tipo de servicio',
        CONCAT(c.nombre, ' ', c.apellidos) AS 'Nombre Cliente',
        t.cuenta_id AS 'No cuenta',
        tc.nombre AS 'Tipo de cuenta',
        t.fecha AS 'Fecha',
        CASE
            WHEN t.tipoTransaccion_id = 1 THEN co.importeCompra
            WHEN t.tipoTransaccion_id = 2 THEN d.monto
            WHEN t.tipoTransaccion_id = 3 THEN deb.monto
            ELSE NULL
        END AS 'Monto',
        t.otrosDetalles AS 'Otros detalles'
    FROM 
        Transaccion t
    LEFT JOIN 
        TipoTransaccion tt ON t.tipoTransaccion_id = tt.idTipoTransaccion
    LEFT JOIN 
        Cuenta cu ON t.cuenta_id = cu.idCuenta
    LEFT JOIN 
        Cliente c ON cu.cliente_id = c.idCliente
    LEFT JOIN 
        Compra co ON t.idGestion = co.idCompra AND t.tipoTransaccion_id = 1
    LEFT JOIN 
        Deposito d ON t.idGestion = d.idDeposito AND t.tipoTransaccion_id = 2
    LEFT JOIN 
        Debito deb ON t.idGestion = deb.idDebito AND t.tipoTransaccion_id = 3
    LEFT JOIN 
        TipoCuenta tc ON cu.tipoCuenta_id = tc.codigo
    WHERE 
        t.fecha BETWEEN fechaInicio AND fechaFin;
END //

DELIMITER ;

/* ============================================CONSULTAR MOVIMIENTOS POR FECHA DE CLIENTE============================================= */
DELIMITER //

CREATE PROCEDURE consultarMovsFechClien (
    IN p_idCliente INT,
    IN p_fechaInicio VARCHAR(10),
    IN p_fechaFin VARCHAR(10)
)
BEGIN
    DECLARE cliente_existe INT;
    DECLARE fechaInicio DATE;
    DECLARE fechaFin DATE;
    
    -- Verificar si el cliente existe
    SELECT COUNT(*) INTO cliente_existe FROM Cliente WHERE idCliente = p_idCliente;
    IF cliente_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El cliente especificado no existe.';
    END IF;

	-- Convertir las fechas al formato 'YYYY-MM-DD' para la consulta
    SET fechaInicio = STR_TO_DATE(p_fechaInicio, '%d/%m/%Y');
    SET fechaFin = STR_TO_DATE(p_fechaFin, '%d/%m/%Y');

    -- Validar si las fechas son válidas
    IF fechaInicio IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El formato de la fecha de inicio no es válido. Utilice el formato DD/MM/YYYY.';
    END IF;

    IF fechaFin IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El formato de la fecha de fin no es válido. Utilice el formato DD/MM/YYYY.';
    END IF;

    -- Consultar los movimientos dentro del rango de fechas especificado para el cliente dado
    SELECT 
        t.idTransaccion AS 'Id transacción',
        tt.nombre AS 'Tipo transacción',
        CASE
            WHEN t.tipoTransaccion_id = 1 THEN 'Compra'
            WHEN t.tipoTransaccion_id = 2 THEN 'Depósito'
            WHEN t.tipoTransaccion_id = 3 THEN 'Débito'
            ELSE NULL
        END AS 'Tipo de servicio',
        CONCAT(c.nombre, ' ', c.apellidos) AS 'Nombre Cliente',
        t.cuenta_id AS 'No cuenta',
        tc.nombre AS 'Tipo de cuenta',
        t.fecha AS 'Fecha',
        CASE
            WHEN t.tipoTransaccion_id = 1 THEN co.importeCompra
            WHEN t.tipoTransaccion_id = 2 THEN d.monto
            WHEN t.tipoTransaccion_id = 3 THEN deb.monto
            ELSE NULL
        END AS 'Monto',
        t.otrosDetalles AS 'Otros detalles'
    FROM 
        Transaccion t
    LEFT JOIN 
        TipoTransaccion tt ON t.tipoTransaccion_id = tt.idTipoTransaccion
    LEFT JOIN 
        Cuenta cu ON t.cuenta_id = cu.idCuenta
    LEFT JOIN 
        Cliente c ON cu.cliente_id = c.idCliente
    LEFT JOIN 
        Compra co ON t.idGestion = co.idCompra AND t.tipoTransaccion_id = 1
    LEFT JOIN 
        Deposito d ON t.idGestion = d.idDeposito AND t.tipoTransaccion_id = 2
    LEFT JOIN 
        Debito deb ON t.idGestion = deb.idDebito AND t.tipoTransaccion_id = 3
    LEFT JOIN 
        TipoCuenta tc ON cu.tipoCuenta_id = tc.codigo
    WHERE 
        c.idCliente = p_idCliente
        AND t.fecha BETWEEN fechaInicio AND fechaFin;
END //

DELIMITER ;

/* ==================================================CONSULTAR PRODUCTOS Y SERVICIOS================================================== */
DELIMITER //

CREATE PROCEDURE consultarProductoServicio ()
BEGIN
    -- Consultar el listado de productos y servicios
    SELECT 
        codigo AS 'Código de producto/servicio',
        descripcion AS 'Descripcion',
        CASE
            WHEN tipo = 1 THEN 'Servicio'
            WHEN tipo = 2 THEN 'Producto'
            ELSE 'Desconocido'
        END AS 'Tipo'
    FROM 
        ProductoServicio;
END //

DELIMITER ;

/* =============================================================FUNCIONES============================================================= */
/* =================================================================================================================================== */
/* ==========================================================VALIDAR LETRAS=========================================================== */
DELIMITER //

CREATE FUNCTION validarLetras (
	p_letras VARCHAR(255)
)
RETURNS BOOLEAN
BEGIN
    DECLARE valido BOOLEAN DEFAULT FALSE;
    
    -- Validar que el texto solo contenga letras y espacios.
    SET valido = p_letras REGEXP '^[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ ]+$';
    
    RETURN valido;
END //

DELIMITER ;

/* =========================================================VALIDAR TELEFONO========================================================= */
DELIMITER //

CREATE FUNCTION validarTelefono (
	p_telefono VARCHAR(255)
)
RETURNS BOOLEAN
BEGIN
	DECLARE valido BOOLEAN DEFAULT FALSE;
    
    SET valido = p_telefono REGEXP '^([0-9]{3})?[0-9]{8}(-([0-9]{3})?[0-9]{8})*$';
    
    RETURN valido;
END //

DELIMITER ;

/* ====================================================OBTENER TELEFONO SIN CODIGO==================================================== */
DELIMITER //

CREATE FUNCTION obtenerTelefonoSinCodigo(
	numero VARCHAR(255)
)
RETURNS VARCHAR(255)
BEGIN
    DECLARE ultimos_digitos VARCHAR(255);
    DECLARE pos_guion INT;
    DECLARE sub_numero VARCHAR(255);
    DECLARE contador INT DEFAULT 0;
    DECLARE resultado VARCHAR(255) DEFAULT '';

    SET pos_guion = INSTR(numero, '-');
    
    WHILE pos_guion > 0 DO
        SET sub_numero = SUBSTRING_INDEX(numero, '-', 1);
        IF LENGTH(sub_numero) >= 8 THEN
            SET resultado = CONCAT(resultado, RIGHT(sub_numero, 8), '-');
        END IF;
        SET numero = SUBSTRING(numero, pos_guion + 1);
        SET pos_guion = INSTR(numero, '-');
    END WHILE;

    IF LENGTH(numero) >= 8 THEN
        SET resultado = CONCAT(resultado, RIGHT(numero, 8));
    END IF;

    RETURN resultado;
END//

DELIMITER ;

/* ==========================================================VALIDAR CORREO========================================================== */
DELIMITER //

CREATE FUNCTION validarCorreo (
	p_correo VARCHAR(255)
)
RETURNS BOOLEAN
BEGIN
    DECLARE valido BOOLEAN DEFAULT FALSE;
    
    SET valido = p_correo REGEXP '^([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})(\\|[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})*$';
    
    RETURN valido;
END //

DELIMITER ;

/* ========================================================INSERTAR TELEFONOS======================================================== */
DELIMITER //

CREATE FUNCTION insertarTelefono (
    cadena_telefonos VARCHAR(255), 
    p_idCliente INT
)
RETURNS INT
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE token VARCHAR(20);
    DECLARE nextDash INT;

    -- Encuentra la primera posición del guion
    SET nextDash = LOCATE('-', cadena_telefonos);

    WHILE nextDash > 0 DO
        -- Extrae el token antes del guion
        SET token = SUBSTRING(cadena_telefonos, 1, nextDash - 1);

        -- Inserta el teléfono en la tabla Telefono
        INSERT INTO Telefono(telefono, cliente_id) VALUES (token, p_idCliente);

        -- Actualiza la cadena para omitir el token que ya hemos procesado
        SET cadena_telefonos = SUBSTRING(cadena_telefonos, nextDash + 1);

        -- Encuentra la próxima posición del guion
        SET nextDash = LOCATE('-', cadena_telefonos);
    END WHILE;

    -- Procesa el último número de teléfono después del último guion
    SET token = cadena_telefonos;
    INSERT INTO Telefono(telefono, cliente_id) VALUES (token, p_idCliente);

    RETURN 1;
END //

DELIMITER ;

/* =============================================================TRIGGERS============================================================= */
/* =================================================================================================================================== */
/* ============================================================TIPOCLIENTE============================================================ */
DELIMITER //
CREATE TRIGGER TipoCliente_Audit_Trigger
AFTER INSERT ON TipoCliente
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla TipoCliente.', 'INSERT');
END//

CREATE TRIGGER TipoCliente_Update_Trigger
AFTER UPDATE ON TipoCliente
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla TipoCliente.', 'UPDATE');
END//

CREATE TRIGGER TipoCliente_Delete_Trigger
AFTER DELETE ON TipoCliente
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla TipoCliente.', 'DELETE');
END//
DELIMITER ;
/* ==============================================================CLIENTE============================================================== */
DELIMITER //
CREATE TRIGGER Cliente_Audit_Trigger
AFTER INSERT ON Cliente
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla Cliente.', 'INSERT');
END//

CREATE TRIGGER Cliente_Update_Trigger
AFTER UPDATE ON Cliente
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla Cliente.', 'UPDATE');
END//

CREATE TRIGGER Cliente_Delete_Trigger
AFTER DELETE ON Cliente
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla Cliente.', 'DELETE');
END//
DELIMITER ;
/* ============================================================TIPOCUENTA============================================================ */
DELIMITER //
CREATE TRIGGER TipoCuenta_Audit_Trigger
AFTER INSERT ON TipoCuenta
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla TipoCuenta.', 'INSERT');
END//

CREATE TRIGGER TipoCuenta_Update_Trigger
AFTER UPDATE ON TipoCuenta
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla TipoCuenta.', 'UPDATE');
END//

CREATE TRIGGER TipoCuenta_Delete_Trigger
AFTER DELETE ON TipoCuenta
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla TipoCuenta.', 'DELETE');
END//
DELIMITER ;
/* ==============================================================CUENTA============================================================== */
DELIMITER //
CREATE TRIGGER Cuenta_Audit_Trigger
AFTER INSERT ON Cuenta
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla Cuenta.', 'INSERT');
END//

CREATE TRIGGER Cuenta_Update_Trigger
AFTER UPDATE ON Cuenta
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla Cuenta.', 'UPDATE');
END//

CREATE TRIGGER Cuenta_Delete_Trigger
AFTER DELETE ON Cuenta
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla Cuenta.', 'DELETE');
END//
DELIMITER ;
/* =========================================================PRODUCTOSERVICIO========================================================= */
DELIMITER //
CREATE TRIGGER ProductoServicio_Audit_Trigger
AFTER INSERT ON ProductoServicio
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla ProductoServicio.', 'INSERT');
END//

CREATE TRIGGER ProductoServicio_Update_Trigger
AFTER UPDATE ON ProductoServicio
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla ProductoServicio.', 'UPDATE');
END//

CREATE TRIGGER ProductoServicio_Delete_Trigger
AFTER DELETE ON ProductoServicio
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla ProductoServicio.', 'DELETE');
END//
DELIMITER ;
/* ==============================================================COMPRA============================================================== */
DELIMITER //
CREATE TRIGGER Compra_Audit_Trigger
AFTER INSERT ON Compra
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla Compra.', 'INSERT');
END//

CREATE TRIGGER Compra_Update_Trigger
AFTER UPDATE ON Compra
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla Compra.', 'UPDATE');
END//

CREATE TRIGGER Compra_Delete_Trigger
AFTER DELETE ON Compra
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla Compra.', 'DELETE');
END//
DELIMITER ;
/* =============================================================DEPOSITO============================================================= */
DELIMITER //
CREATE TRIGGER Deposito_Audit_Trigger
AFTER INSERT ON Deposito
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla Deposito.', 'INSERT');
END//

CREATE TRIGGER Deposito_Update_Trigger
AFTER UPDATE ON Deposito
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla Deposito.', 'UPDATE');
END//

CREATE TRIGGER Deposito_Delete_Trigger
AFTER DELETE ON Deposito
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla Deposito.', 'DELETE');
END//
DELIMITER ;
/* ==============================================================DEBITO============================================================== */
DELIMITER //
CREATE TRIGGER Debito_Audit_Trigger
AFTER INSERT ON Debito
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla Debito.', 'INSERT');
END//

CREATE TRIGGER Debito_Update_Trigger
AFTER UPDATE ON Debito
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla Debito.', 'UPDATE');
END//

CREATE TRIGGER Debito_Delete_Trigger
AFTER DELETE ON Debito
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla Debito.', 'DELETE');
END//
DELIMITER ;
/* =========================================================TIPOTRANSACCION========================================================== */
DELIMITER //
CREATE TRIGGER TipoTransaccion_Audit_Trigger
AFTER INSERT ON TipoTransaccion
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla TipoTransaccion.', 'INSERT');
END//

CREATE TRIGGER TipoTransaccion_Update_Trigger
AFTER UPDATE ON TipoTransaccion
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla TipoTransaccion.', 'UPDATE');
END//

CREATE TRIGGER TipoTransaccion_Delete_Trigger
AFTER DELETE ON TipoTransaccion
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla TipoTransaccion.', 'DELETE');
END//
DELIMITER ;
/* ===========================================================TRANSACCION============================================================ */
DELIMITER //
CREATE TRIGGER Transaccion_Audit_Trigger
AFTER INSERT ON Transaccion
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla Transaccion.', 'INSERT');
END//

CREATE TRIGGER Transaccion_Update_Trigger
AFTER UPDATE ON Transaccion
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla Transaccion.', 'UPDATE');
END//

CREATE TRIGGER Transaccion_Delete_Trigger
AFTER DELETE ON Transaccion
FOR EACH ROW
BEGIN
    INSERT INTO Historial (fecha, descripcion, tipo)
    VALUES (NOW(), 'Se ha realizado una acción en la tabla Transaccion.', 'DELETE');
END//
DELIMITER ;

/* =====================================================LLAMADAS A PROCEDIMIENTOS===================================================== */
/* =================================================================================================================================== */

-- registrarTipoCliente
-- idtipo, nombre, descripcion
CALL registrarTipoCliente(1, 'Individual Nacional', 'Este tipo de cliente es una persona individual de nacionalidad guatemalteca');
CALL registrarTipoCliente(2, 'Individual Extranjero', 'Este tipo de cliente es una persona individual de nacionalidad extranjera');
CALL registrarTipoCliente(3, 'Empresa PyMe', 'Este tipo de cliente es una empresa de tipo pequeña o mediana');
CALL registrarTipoCliente(4, 'Empresa S.C', 'Este tipo de cliente corresponde a las empresa grandes que tienen una sociedad colectiva');

-- registrarTipoCuenta
-- idtipo, nombre, descripcion
CALL registrarTipoCuenta(1,'Cuenta de Cheques','Este tipo de cuenta ofrece la facilidad de emitir cheques para realizar transacciones monetarias');
CALL registrarTipoCuenta(2,'Cuenta de Ahorros','Esta cuenta genera un interés anual del 2% lo que la hace ideal para guardar fondos a largo plazo');
CALL registrarTipoCuenta(3,'Cuenta de Ahorro Plus','Con una tasa de interés anual del 10% esta cuenta de ahorros ofrece mayores rendimientos');
CALL registrarTipoCuenta(4,'Pequeña Cuenta','Una cuenta de ahorros con un interés semestral del 0.5% ideal para pequeños ahorros y movimientos');
CALL registrarTipoCuenta(5,'Cuenta de Nómina','Diseñada para recibir depósitos de sueldo y realizar pagos con acceso a servicios bancarios básicos');
CALL registrarTipoCuenta(6,'Cuenta de Inversión','Orientada a inversionistas ofrece opciones de inversión y rendimientos más altos que una cuenta de ahorros estándar');

-- crearProductoServicio
-- id, tipo, costo, descripcion
CALL crearProductoServicio(1, 1, 10.00, 'Servicio de tarjeta de debito');
CALL crearProductoServicio(2, 1, 10.00, 'Servicio de chequera');
CALL crearProductoServicio(3, 1, 400.00, 'Servicio de asesoramiento financiero');
CALL crearProductoServicio(4, 1, 5.00, 'Servicio de banca personal');
CALL crearProductoServicio(5, 1, 30.00, 'Seguro de vida');
CALL crearProductoServicio(6, 1, 100.00, 'Seguro de vida plus');
CALL crearProductoServicio(7, 1, 300.00, 'Seguro de automóvil');
CALL crearProductoServicio(8, 1, 500.00, 'Seguro de automóvil plus');
CALL crearProductoServicio(9, 1, 00.05, 'Servicio de deposito');
CALL crearProductoServicio(10, 1, 00.10, 'Servicio de Debito');
CALL crearProductoServicio(11, 2, 0, 'Pago de energía Eléctrica (EEGSA)');
CALL crearProductoServicio(12, 2, 0, 'Pago de agua potable (Empagua)');
CALL crearProductoServicio(13, 2, 0, 'Pago de Matricula USAC');
CALL crearProductoServicio(14, 2, 0, 'Pago de curso vacaciones USAC');
CALL crearProductoServicio(15, 2, 0, 'Pago de servicio de internet');
CALL crearProductoServicio(16, 2, 0, 'Servicio de suscripción plataformas streaming');
CALL crearProductoServicio(17, 2, 0, 'Servicios Cloud');

-- registrar tipo de transaccion
-- id, nombre, descripcion
CALL registrarTipoTransaccion(1, 'Compra', 'Transacción de compra');
CALL registrarTipoTransaccion(2, 'Deposito', 'Transacción de deposito');
CALL registrarTipoTransaccion(3, 'Debito', 'Transacción de debito');