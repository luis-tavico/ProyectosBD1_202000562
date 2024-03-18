from flask import Flask, jsonify
import pymysql
import pandas
from datetime import datetime

app = Flask(__name__)

# Conexion a la base de datos en MySQL
connection = pymysql.connect(
    host='localhost',
    user='root',
    password='admin123',
    database='empresa',
    cursorclass=pymysql.cursors.DictCursor
)

# Definir una ruta para la pagina principal
@app.route('/')
def index():
    return 'Bienvenido a la API del Proyecto 1'

# Mostrar el cliente que mas ha comprado. Se debe de mostrar el id del cliente, nombre, apellido, pais y monto total.
@app.route('/consulta1', methods=['GET'])
def get_query1():
    try:
        with connection.cursor() as cursor:
            query = """
            SELECT cliente.id AS id_cliente,
                cliente.nombre AS nombre_cliente,
                cliente.apellido AS apellido_cliente,
                pais.nombre AS pais_cliente,
                SUM(detalle_orden.cantidad * producto.precio) AS monto_total
            FROM cliente
            JOIN orden ON cliente.id = orden.cliente_id
            JOIN detalle_orden ON orden.id = detalle_orden.orden_id
            JOIN producto ON detalle_orden.producto_id = producto.id
            JOIN pais ON cliente.pais_id = pais.id
            GROUP BY cliente.id
            ORDER BY monto_total DESC
            LIMIT 1;
            """
            cursor.execute(query)
            customer = cursor.fetchone()
    except Exception as e:
        return f"Error: {str(e)}"
    finally:
        cursor.close()
    return jsonify(customer)

# Mostrar el producto mas y menos comprado. Se debe mostrar el id del producto, nombre del producto, categoria, cantidad de unidades y monto vendido.
@app.route('/consulta2', methods=['GET'])
def get_query2():
    try:
        result = {}
        with connection.cursor() as cursor:
            # Buscar producto mas comprado
            query = """
            SELECT producto.id AS id_producto,
                producto.nombre AS nombre_producto,
                categoria.nombre AS categoria_producto,
                SUM(detalle_orden.cantidad) AS cantidad_unidades,
                SUM(detalle_orden.cantidad * producto.precio) AS monto_vendido
            FROM producto
            JOIN detalle_orden ON producto.id = detalle_orden.producto_id
            JOIN categoria ON producto.categoria_id = categoria.id
            GROUP BY producto.id
            ORDER BY cantidad_unidades DESC
            LIMIT 1;
            """
            cursor.execute(query)
            product = cursor.fetchone()
            result['producto_mas_comprado'] = product
            # Buscar producto menos comprado
            query = """
            SELECT producto.id AS id_producto,
                producto.nombre AS nombre_producto,
                categoria.nombre AS categoria_producto,
                SUM(detalle_orden.cantidad) AS cantidad_unidades,
                SUM(detalle_orden.cantidad * producto.precio) AS monto_vendido
            FROM producto
            JOIN detalle_orden ON producto.id = detalle_orden.producto_id
            JOIN categoria ON producto.categoria_id = categoria.id
            GROUP BY producto.id
            ORDER BY cantidad_unidades ASC
            LIMIT 1;
            """
            cursor.execute(query)
            product = cursor.fetchone()
            result['producto_menos_comprado'] = product
    except Exception as e:
        return f"Error: {str(e)}"
    finally:
        cursor.close()
    return jsonify(result)

# Mostrar a la persona que mas ha vendido. Se debe mostrar el id del vendedor, nombre del vendedor, monto total vendido.
@app.route('/consulta3', methods=['GET'])
def get_query3():
    try:
        with connection.cursor() as cursor:
            query = """
            SELECT vendedor.id AS id_vendedor,
                vendedor.nombre AS nombre_vendedor,
                SUM(detalle_orden.cantidad * producto.precio) AS monto_total_vendido
            FROM vendedor
            JOIN detalle_orden ON vendedor.id = detalle_orden.vendedor_id
            JOIN producto ON detalle_orden.producto_id = producto.id
            GROUP BY vendedor.id
            ORDER BY monto_total_vendido DESC
            LIMIT 1;
            """
            cursor.execute(query)
            seller = cursor.fetchone()
    except Exception as e:
        return f"Error: {str(e)}"
    finally:
        cursor.close()
    return jsonify(seller)

# Mostrar el país que mas y menos ha vendido. Debe mostrar el nombre del pais y el monto. (Una sola consulta).
@app.route('/consulta4', methods=['GET'])
def get_query4():
    try:
        with connection.cursor() as cursor:
            query = """
            SELECT * FROM (
                SELECT pais.nombre AS nombre_pais,
                SUM(detalle_orden.cantidad * producto.precio) AS monto_total_vendido
                FROM detalle_orden
                INNER JOIN vendedor ON detalle_orden.vendedor_id = vendedor.id
                INNER JOIN pais ON vendedor.pais_id = pais.id
                INNER JOIN producto ON detalle_orden.producto_id = producto.id
                GROUP BY pais.nombre
                ORDER BY monto_total_vendido DESC
                LIMIT 1
            ) AS max_total
            UNION
            SELECT * FROM (
                SELECT pais.nombre AS nombre_pais,
                SUM(detalle_orden.cantidad * producto.precio) AS monto_total_vendido
                FROM detalle_orden
                INNER JOIN vendedor ON detalle_orden.vendedor_id = vendedor.id
                INNER JOIN pais ON vendedor.pais_id = pais.id
                INNER JOIN producto ON detalle_orden.producto_id = producto.id
                GROUP BY pais.nombre
                ORDER BY monto_total_vendido ASC
                LIMIT 1
            ) AS min_total;
            """
            cursor.execute(query)
            countries = cursor.fetchall()
    except Exception as e:
        return f"Error: {str(e)}"
    finally:
        cursor.close()
    return jsonify(countries)

# Top 5 de paises que mas han comprado en orden ascendente. Se le solicita mostrar el id del pais, nombre y monto total.
@app.route('/consulta5', methods=['GET'])
def get_query5():
    try:
        with connection.cursor() as cursor:
            query = """
            SELECT pais.id AS id_pais,
                pais.nombre AS nombre_pais,
                SUM(detalle_orden.cantidad * producto.precio) AS monto_total_comprado
            FROM pais
            JOIN cliente ON pais.id = cliente.pais_id
            JOIN orden ON cliente.id = orden.cliente_id
            JOIN detalle_orden ON orden.id = detalle_orden.orden_id
            JOIN producto ON detalle_orden.producto_id = producto.id
            GROUP BY pais.id
            ORDER BY monto_total_comprado ASC
            LIMIT 5;
            """
            cursor.execute(query)
            countries = cursor.fetchall()
    except Exception as e:
        return f"Error: {str(e)}"
    finally:
        cursor.close()
    return jsonify(countries)

# Mostrar la categoria que mas y menos se ha comprado. Debe de mostrar el nombre de la categoria y cantidad de unidades. (Una sola consulta).
@app.route('/consulta6', methods=['GET'])
def get_query6():
    try:
        result = {}
        with connection.cursor() as cursor:
            # Buscar categoria que mas se ha comprado
            query = """
            SELECT * FROM (
                SELECT categoria.nombre AS nombre_categoria, 
                SUM(detalle_orden.cantidad) AS cantidad_total
                FROM detalle_orden
                INNER JOIN producto ON detalle_orden.producto_id = producto.id
                INNER JOIN categoria ON producto.categoria_id = categoria.id
                GROUP BY categoria.nombre
                ORDER BY cantidad_total DESC
                LIMIT 1
            ) AS max_total
            UNION
            SELECT * FROM (
                SELECT categoria.nombre AS nombre_categoria, 
                SUM(detalle_orden.cantidad) AS cantidad_total
                FROM detalle_orden
                INNER JOIN producto ON detalle_orden.producto_id = producto.id
                INNER JOIN categoria ON producto.categoria_id = categoria.id
                GROUP BY categoria.nombre
                ORDER BY cantidad_total ASC
                LIMIT 1
            ) AS min_total;
            """
            cursor.execute(query)
            result['categoria_mas_comprada'] = cursor.fetchall()
    except Exception as e:
        return f"Error: {str(e)}"
    finally:
        cursor.close()
    return jsonify(result)

# Mostrar la categoria mas comprada por cada país. Se debe de mostrar el nombre del pais, nombre de la categoria y cantidad de unidades.
@app.route('/consulta7', methods=['GET'])
def get_query7():
    try:
        with connection.cursor() as cursor:
            # Buscar la categoria mas comprada por cada pais
            query = """
            SELECT
                resultado_pais.*
            FROM
                (SELECT
                    pais.nombre AS pais,
                    categoria.nombre AS categoría,
                    SUM(detalle_orden.cantidad) AS cantidad_unidades
                FROM detalle_orden
                JOIN producto ON detalle_orden.producto_id = producto.id
                JOIN categoria ON producto.categoria_id = categoria.id
                JOIN orden ON detalle_orden.orden_id = orden.id
                JOIN cliente ON orden.cliente_id = cliente.id
                JOIN pais ON cliente.pais_id = pais.id
                GROUP BY pais.nombre, categoria.nombre
                ORDER BY pais.nombre, cantidad_unidades DESC) AS resultado_pais
            GROUP BY resultado_pais.pais
            ORDER BY resultado_pais.pais;
            """
            cursor.execute(query)
            categories = cursor.fetchall()
    except Exception as e:
        return f"Error: {str(e)}"
    finally:
        cursor.close()
    return jsonify(categories)

# Mostrar las ventas por mes de Inglaterra. Debe de mostrar el numero del mes y el monto.
@app.route('/consulta8', methods=['GET'])
def get_query8():
    try:
        with connection.cursor() as cursor:
            query = """
            SELECT MONTH(orden.fecha) AS numero_mes,
            SUM(detalle_orden.cantidad * producto.precio) AS monto_total
            FROM detalle_orden
            JOIN orden ON detalle_orden.orden_id = orden.id
            JOIN cliente ON orden.cliente_id = cliente.id
            JOIN pais ON cliente.pais_id = pais.id
            JOIN producto ON detalle_orden.producto_id = producto.id
            WHERE pais.nombre = 'Inglaterra'
            GROUP BY MONTH(orden.fecha)
            ORDER BY numero_mes;
            """
            cursor.execute(query)
            sales = cursor.fetchall()
    except Exception as e:
        return f"Error: {str(e)}"
    finally:
        cursor.close()
    return jsonify(sales)

# Mostrar el mes con mas y menos ventas. Se debe de mostrar el numero de mes y monto. (Una sola consulta).
@app.route('/consulta9', methods=['GET'])
def get_query9():
    try:
        with connection.cursor() as cursor:
            query = """
            SELECT mes, monto FROM (
            SELECT 
            MONTH(orden.fecha) AS mes,
            SUM(detalle_orden.cantidad * producto.precio) AS monto
            FROM orden
            INNER JOIN detalle_orden ON orden.id = detalle_orden.orden_id
            INNER JOIN producto ON detalle_orden.producto_id = producto.id
            GROUP BY MONTH(orden.fecha)
            ORDER BY monto DESC
            LIMIT 1
            ) AS maximo_venta
            UNION
            SELECT mes, monto FROM ( 
            SELECT 
            MONTH(orden.fecha) AS mes,
            SUM(detalle_orden.cantidad * producto.precio) AS monto
            FROM orden 
            INNER JOIN detalle_orden ON orden.id = detalle_orden.orden_id
            INNER JOIN producto ON detalle_orden.producto_id = producto.id
            GROUP BY MONTH(orden.fecha)
            ORDER BY monto ASC
            LIMIT 1
            ) AS minimo_venta;
            """
            cursor.execute(query)
            months = cursor.fetchall()
    except Exception as e:
        return f"Error: {str(e)}"
    finally:
        cursor.close()
    return jsonify(months)

# Mostrar las ventas de cada producto de la categoria deportes. Se debe de mostrar el id del producto, nombre y monto.
@app.route('/consulta10', methods=['GET'])
def get_query10():
    try:
        with connection.cursor() as cursor:
            query = """
            SELECT producto.id AS id_producto,
                producto.nombre AS nombre_producto,
                SUM(detalle_orden.cantidad * producto.precio) AS monto_total
            FROM producto
            JOIN categoria ON producto.categoria_id = categoria.id
            JOIN detalle_orden ON producto.id = detalle_orden.producto_id
            WHERE categoria.nombre = 'Deportes'
            GROUP BY producto.id, producto.nombre;
            """
            cursor.execute(query)
            sales = cursor.fetchall()
    except Exception as e:
        return f"Error: {str(e)}"
    finally:
        cursor.close()
    return jsonify(sales)

# Eliminar las tablas de la base de datos
@app.route('/eliminarmodelo', methods=['GET'])
def get_delete_model():
    try:
        with connection.cursor() as cursor:
            queries = [
                "DROP TABLE detalle_orden;",
                "DROP TABLE orden;",
                "DROP TABLE cliente;",
                "DROP TABLE vendedor;",
                "DROP TABLE pais;",
                "DROP TABLE producto;",
                "DROP TABLE categoria;"
            ]
            for query in queries:
                cursor.execute(query)
            connection.commit()
    except Exception as e:
        return f"Error: {str(e)}"
    finally:
        cursor.close()
    return jsonify({'message': 'Modelo eliminado correctamente'})

# Crear tablas del modelo
@app.route('/crearmodelo', methods=['GET'])
def get_create_model():
    try:
        with connection.cursor() as cursor:
            queries = [
                """DROP DATABASE IF EXISTS empresa;""",
                """CREATE DATABASE empresa;""",
                """USE empresa;""",
                """
                CREATE TABLE categoria (
                    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                    nombre VARCHAR (255) NOT NULL
                );
                """,   
                """
                CREATE TABLE producto (
                    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                    nombre VARCHAR (255) NOT NULL,
                    precio DECIMAL (10, 2) NOT NULL,
                    categoria_id INT NOT NULL,
                    FOREIGN KEY (categoria_id) REFERENCES categoria(id)
                );
                """,
                """
                CREATE TABLE pais (
                    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                    nombre VARCHAR (255) NOT NULL
                );
                """,
                """
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
                """,
                """
                CREATE TABLE vendedor (
                    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                    nombre VARCHAR (255) NOT NULL,
                    pais_id INT NOT NULL,
                    FOREIGN KEY (pais_id) REFERENCES pais(id)
                );
                """,
                """
                CREATE TABLE orden (
                    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                    fecha DATE NOT NULL,
                    cliente_id INT NOT NULL,
                    FOREIGN KEY (cliente_id) REFERENCES cliente(id)
                );
                """,
                """
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
                """
            ]
            for query in queries:
                cursor.execute(query)
            connection.commit()
    except Exception as e:
        return f"Error: {str(e)}"
    finally:
        cursor.close()
    return jsonify({'message': 'Modelo creado correctamente'})

# Eliminar información de tablas
@app.route('/borrarinfodb', methods=['GET'])
def get_delete_info():
    try:
        with connection.cursor() as cursor:
            queries = [
                "DELETE FROM detalle_orden;",
                "DELETE FROM orden;",
                "DELETE FROM cliente;",
                "DELETE FROM vendedor;",
                "DELETE FROM pais;",
                "DELETE FROM producto;",
                "DELETE FROM categoria;"
            ]            
            for query in queries:
                cursor.execute(query)
            connection.commit()
    except Exception as e:
        return f"Error: {str(e)}"
    finally:
        cursor.close()
    return jsonify({'message': 'Informacion eliminada correctamente'})

# Cargar datos a modelo
@app.route('/cargarmodelo', methods=['GET'])
def get_load_model():
    try:
        # Cargar categorias en la base de datos
        df_categories = pandas.read_csv('Proyecto1/archivos/Categorias.csv', delimiter=';')
        with connection.cursor() as cursor:
            for index, row in df_categories.iterrows():
                id_category = row['id_categoria']
                name = row['nombre']
                sql = "INSERT INTO categoria (id, nombre) VALUES (%s, %s)"
                cursor.execute(sql, (id_category, name))
            # Guardar cambios en la base de datos
            connection.commit()
        # Cargar productos en la base de datos
        df_products = pandas.read_csv('Proyecto1/archivos/productos.csv', delimiter=';')
        with connection.cursor() as cursor:
            for index, row in df_products.iterrows():
                id_product = row['id_producto']
                name = row['Nombre']
                price = float(row['Precio'])
                id_category = row['id_categoria']
                sql = "INSERT INTO producto (id, nombre, precio, categoria_id) VALUES (%s, %s, %s, %s)"
                cursor.execute(sql, (id_product, name, price, id_category))
            # Guardar cambios en la base de datos
            connection.commit()
        # Cargar paises en la base de datos
        df_countries = pandas.read_csv('Proyecto1/archivos/paises.csv', delimiter=';')
        with connection.cursor() as cursor:
            for index, row in df_countries.iterrows():
                id_country = row['id_pais']
                name = row['nombre']
                sql = "INSERT INTO pais (id, nombre) VALUES (%s, %s)"
                cursor.execute(sql, (id_country, name))
            # Guardar cambios en la base de datos
            connection.commit()
        # Cargar clientes en la base de datos
        df_customers = pandas.read_csv('Proyecto1/archivos/clientes.csv', delimiter=';')
        with connection.cursor() as cursor:
            for index, row in df_customers.iterrows():
                id_customer = row['id_cliente']
                name = row['Nombre']
                lastname = row['Apellido']
                address = row['Direccion']
                phone = row['Telefono']
                card = row['Tarjeta']
                age = row['Edad']
                salary = float(row['Salario'])
                gender = row['Genero']
                id_country = row['id_pais']
                sql = "INSERT INTO cliente (id, nombre, apellido, direccion, telefono, tarjeta_credito, edad, salario, genero, pais_id) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
                cursor.execute(sql, (id_customer, name, lastname, address, phone, card, age, salary, gender, id_country))
            # Guardar cambios en la base de datos
            connection.commit()
        # Cargar vendedores en la base de datos         
        df_sellers = pandas.read_csv('Proyecto1/archivos/vendedores.csv', delimiter=';')
        with connection.cursor() as cursor:
            for index, row in df_sellers.iterrows():
                id_seller = row['id_vendedor']
                name = row['nombre']
                id_country = row['id_pais']
                sql = "INSERT INTO vendedor (id, nombre, pais_id) VALUES (%s, %s, %s)"
                cursor.execute(sql, (id_seller, name, id_country))
            # Guardar cambios en la base de datos
            connection.commit()
        # Cargar ordenes en la base de datos
        id_order_current = 0
        df_orders = pandas.read_csv('Proyecto1/archivos/ordenes.csv', delimiter=';')
        with connection.cursor() as cursor:
            for index, row in df_orders.iterrows():
                if id_order_current != row['id_orden']:
                    id_order_current = row['id_orden'] # Actualizar el id de la orden
                    date = row['fecha_orden']
                    date_datetime = datetime.strptime(date, "%d/%m/%Y")
                    date_converted = date_datetime.strftime("%Y-%m-%d")
                    id_customer = row['id_cliente']
                    sql = "INSERT INTO orden (id, fecha, cliente_id) VALUES (%s, %s, %s)"
                    cursor.execute(sql, (id_order_current, date_converted, id_customer))
                line = row['linea_orden']
                amount = row['cantidad']
                id_product = row['id_producto']
                id_seller = row['id_vendedor']
                id_order = row['id_orden']
                sql = "INSERT INTO detalle_orden (id, linea_orden, cantidad, producto_id, vendedor_id, orden_id) VALUES (%s, %s, %s, %s, %s, %s)"
                cursor.execute(sql, (index+1, line, amount, id_product, id_seller, id_order))
            # Guardar cambios en la base de datos
            connection.commit()
        return jsonify({'message': 'Modelo cargado correctamente'})
    except Exception as e:
        print(f"Error: {str(e)}")
    finally:
        connection.close()

if __name__ == '__main__':
    app.run(debug=True)