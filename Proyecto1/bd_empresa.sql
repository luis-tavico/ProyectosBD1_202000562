DROP DATABASE IF EXISTS empresa;

CREATE DATABASE empresa;

USE empresa;

CREATE TABLE categoria (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	nombre VARCHAR (255) NOT NULL
);

CREATE TABLE producto (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR (255) NOT NULL,
    precio DECIMAL (10, 2) NOT NULL,
    categoria_id INT NOT NULL,
	FOREIGN KEY (categoria_id) REFERENCES categoria(id)
);

CREATE TABLE pais (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR (255) NOT NULL
);

CREATE TABLE cliente (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR (255) NOT NULL,
    apellido VARCHAR (255) NOT NULL,
    direccion VARCHAR (255) NOT NULL,
    telefono VARCHAR (255) NOT NULL,
    tarjeta_credito VARCHAR (255) NOT NULL,
    edad INT NOT NULL,
	salario DECIMAL (10,2) NOT NULL,
    genero VARCHAR (255) NOT NULL,
    pais_id INT NOT NULL,
	FOREIGN KEY (pais_id) REFERENCES pais(id)
);

CREATE TABLE vendedor (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR (255) NOT NULL,
    pais_id INT NOT NULL,
	FOREIGN KEY (pais_id) REFERENCES pais(id)
);

CREATE TABLE orden (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    cliente_id INT NOT NULL,
	FOREIGN KEY (cliente_id) REFERENCES cliente(id)
);

CREATE TABLE detalle_orden (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    linea_orden INT NOT NULL,
    cantidad INT NOT NULL,
    producto_id INT NOT NULL,
    vendedor_id INT NOT NULL,
    orden_id INT NOT NULL,
	FOREIGN KEY (producto_id) REFERENCES producto(id),
	FOREIGN KEY (vendedor_id) REFERENCES vendedor(id),
	FOREIGN KEY (orden_id) REFERENCES orden(id)
);