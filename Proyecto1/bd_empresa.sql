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
    id_categoria INT NOT NULL
	-- FOREIGN KEY (id_categoria) REFERENCES categoria(id)
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
	salario VARCHAR (255) NOT NULL,
    genero VARCHAR (255) NOT NULL,
    id_pais INT NOT NULL
);

CREATE TABLE vendedor (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR (255) NOT NULL,
    id_pais INT NOT NULL
);

CREATE TABLE orden (
	id INT NOT NULL,
    linea_orden INT NOT NULL,
    fecha DATE NOT NULL,
    id_cliente INT NOT NULL,
    id_vendedor INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL
);