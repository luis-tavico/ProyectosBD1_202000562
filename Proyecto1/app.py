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
    return 'Bienvenido a la API de Proyecto 1'

@app.route('/consulta1', methods=['GET'])
def get_consulta1():
    try:
        with connection.cursor() as cursor:
            sql = """
            SELECT id_producto, SUM(cantidad) AS total_comprado
            FROM orden
            GROUP BY id_producto
            ORDER BY total_comprado DESC
            LIMIT 1
            """
            cursor.execute(sql)
            producto_mas_comprado = cursor.fetchone()
            #
            prod_mas_menos_comprado = {
                'id_producto_mas_comprado': producto_mas_comprado['id_producto'],
                'total_comprado_mas_comprado': producto_mas_comprado['total_comprado']
            }
            #
            sql = """
            SELECT id_producto, SUM(cantidad) AS total_comprado
            FROM orden
            GROUP BY id_producto
            ORDER BY total_comprado ASC
            LIMIT 1
            """
            cursor.execute(sql)
            producto_menos_comprado = cursor.fetchone()
            #
            prod_mas_menos_comprado['id_producto_menos_comprado'] = producto_menos_comprado['id_producto'],
            prod_mas_menos_comprado['total_comprado_menos_comprado'] = producto_menos_comprado['total_comprado']
            #
    except Exception as e:
        return f"Error: {str(e)}"
    finally:
        cursor.close()
    return jsonify(prod_mas_menos_comprado)
    
@app.route('/cargarmodelo', methods=['GET'])
def get_load_model():
    try:
        # Cargar categorias en la base de datos
        df_categories = pandas.read_csv('archivos/Categorias.csv', delimiter=';')
        with connection.cursor() as cursor:
            for index, row in df_categories.iterrows():
                id_category = row['id_categoria']
                name = row['nombre']
                sql = "INSERT INTO categoria (id, nombre) VALUES (%s, %s)"
                cursor.execute(sql, (id_category, name))
            # Guardar cambios en la base de datos
            connection.commit()
        # Cargar productos en la base de datos
        df_products = pandas.read_csv('archivos/productos.csv', delimiter=';')
        with connection.cursor() as cursor:
            for index, row in df_products.iterrows():
                id_product = row['id_producto']
                name = row['Nombre']
                price = float(row['Precio'])
                id_category = row['id_categoria']
                sql = "INSERT INTO producto (id, nombre, precio, id_categoria) VALUES (%s, %s, %s, %s)"
                cursor.execute(sql, (id_product, name, price, id_category))
            # Guardar cambios en la base de datos
            connection.commit()
        '''
        # Cargar paises en la base de datos
        df_countries = pandas.read_csv('archivos/paises.csv', delimiter=';')
        with connection.cursor() as cursor:
            for index, row in df_countries.iterrows():
                id_country = row['id_pais']
                name = row['nombre']
                sql = "INSERT INTO pais (id, nombre) VALUES (%s, %s)"
                cursor.execute(sql, (id_country, name))
            # Guardar cambios en la base de datos
            connection.commit()
        # Cargar clientes en la base de datos
        df_customers = pandas.read_csv('archivos/clientes.csv', delimiter=';')
        with connection.cursor() as cursor:
            for index, row in df_customers.iterrows():
                id_customer = row['id_cliente']
                name = row['Nombre']
                lastname = row['Apellido']
                address = row['Direccion']
                phone = row['Telefono']
                card = row['Tarjeta']
                age = row['Edad']
                salary = row['Salario']
                gender = row['Genero']
                id_country = row['id_pais']
                sql = "INSERT INTO cliente (id, nombre, apellido, direccion, telefono, tarjeta_credito, edad, salario, genero, id_pais) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
                cursor.execute(sql, (id_customer, name, lastname, address, phone, card, age, salary, gender, id_country))
            # Guardar cambios en la base de datos
            connection.commit()
        # Cargar vendedores en la base de datos         
        df_sellers = pandas.read_csv('archivos/vendedores.csv', delimiter=';')
        with connection.cursor() as cursor:
            for index, row in df_sellers.iterrows():
                id_seller = row['id_vendedor']
                name = row['nombre']
                id_country = row['id_pais']
                sql = "INSERT INTO vendedor (id, nombre, id_pais) VALUES (%s, %s, %s)"
                cursor.execute(sql, (id_seller, name, id_country))
            # Guardar cambios en la base de datos
            connection.commit()
        '''
        # Cargar ordenes en la base de datos
        df_orders = pandas.read_csv('archivos/ordenes.csv', delimiter=';')
        with connection.cursor() as cursor:
            for index, row in df_orders.iterrows():
                id_order = row['id_orden']
                line = row['linea_orden']
                date = row['fecha_orden']
                # Convertir la fecha a formato datetime
                fecha_datetime = datetime.strptime(date, "%d/%m/%Y")
                # Convertir la fecha a formato "AAAA-MM-DD"
                fecha_convertida = fecha_datetime.strftime("%Y-%m-%d")
                #
                id_customer = row['id_cliente']
                id_seller = row['id_vendedor']
                id_product = row['id_producto']
                amount = row['cantidad']
                sql = "INSERT INTO orden (id, linea_orden, fecha, id_cliente, id_vendedor, id_producto, cantidad) VALUES (%s, %s, %s, %s, %s, %s, %s)"
                cursor.execute(sql, (id_order, line, fecha_convertida, id_customer, id_seller, id_product, amount))
            # Guardar cambios en la base de datos
            connection.commit()
        #return 'Datos cargados en la base de datos correctamente.'
        return jsonify({'message': 'Modelo cargado correctamente'})
    except Exception as e:
        print(f"Error: {str(e)}")
    finally:
        connection.close()

@app.route('/consulta', methods=['GET'])
def get_consulta():
    try:
        with connection.cursor() as cursor:
            sql = "SELECT * FROM orden"
            cursor.execute(sql)
            consulta = cursor.fetchall()
            '''
            # Convertir precio a Decimal
            for producto in consulta:
                producto['precio'] = float(producto['precio'])
            '''
    except Exception as e:
        return f"Error: {str(e)}"
    finally:
        cursor.close()
    return jsonify(consulta)

if __name__ == '__main__':
    app.run(debug=True)
