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
    id_categoria INT NOT NULL,
	FOREIGN KEY (id_categoria) REFERENCES categoria(id)
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
    id_pais INT NOT NULL,
	FOREIGN KEY (id_pais) REFERENCES pais(id)
);

CREATE TABLE vendedor (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR (255) NOT NULL,
    id_pais INT NOT NULL,
	FOREIGN KEY (id_pais) REFERENCES pais(id)
);

CREATE TABLE orden (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    id_cliente INT NOT NULL,
	FOREIGN KEY (id_cliente) REFERENCES cliente(id)
);

CREATE TABLE detalle_orden (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_orden INT NOT NULL,
    linea_orden INT NOT NULL,
    id_vendedor INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
	FOREIGN KEY (id_orden) REFERENCES orden(id),
	FOREIGN KEY (id_vendedor) REFERENCES vendedor(id),
	FOREIGN KEY (id_producto) REFERENCES producto(id)
);