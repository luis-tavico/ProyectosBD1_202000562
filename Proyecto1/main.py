from flask import Flask, jsonify, request
import csv
import mysql.connector

app = Flask(__name__)

db = mysql.connector.connect(
    host="localhost",
    port= '3306',
    user="root",
    password="admin123",
    database="empresa"
)

@app.route('/')
def index():
    return "Proyecto 1"

# Mostrar el cliente que mas ha comprado. Se debe de mostrar el id del cliente, nombre, apellido, pais y monto total.
@app.route('/consulta1', methods=['GET'])
def get_consulta1():
    datos = {
        'nombre': 'Juan',
        'apellido': 'Perez',
        'edad': 30
    }
    return jsonify(datos)

# Mostrar el producto mas y menos comprado. Se debe mostrar el id del producto, nombre del producto, categoria, cantidad de unidades y monto vendido.
@app.route('/consulta2', methods=['GET'])
def get_consulta2():
    datos = {
        'nombre': 'Juan',
        'apellido': 'Perez',
        'edad': 30
    }
    return jsonify(datos)

# Mostrar a la persona que mas ha vendido. Se debe mostrar el id del vendedor, nombre del vendedor, monto total vendido.
@app.route('/consulta3', methods=['GET'])
def get_consulta3():
    datos = {
        'nombre': 'Juan',
        'apellido': 'Perez',
        'edad': 30
    }
    return jsonify(datos)

# Mostrar el país que mas y menos ha vendido. Debe mostrar el nombre del pais y el monto. (Una sola consulta).
@app.route('/consulta4', methods=['GET'])
def get_consulta4():
    datos = {
        'nombre': 'Juan',
        'apellido': 'Perez',
        'edad': 30
    }
    return jsonify(datos)

# Top 5 de paises que mas han comprado en orden ascendente. Se le solicita mostrar el id del pais, nombre y monto total.
@app.route('/consulta5', methods=['GET'])
def get_consulta5():
    datos = {
        'nombre': 'Juan',
        'apellido': 'Perez',
        'edad': 30
    }
    return jsonify(datos)

# Mostrar la categoria que mas y menos se ha comprado. Debe de mostrar el nombre de la categoria y cantidad de unidades. (Una sola consulta).
@app.route('/consulta6', methods=['GET'])
def get_consulta6():
    datos = {
        'nombre': 'Juan',
        'apellido': 'Perez',
        'edad': 30
    }
    return jsonify(datos)

# Mostrar la categoria mas comprada por cada país. Se debe de mostrar el nombre del pais, nombre de la categoria y cantidad de unidades.
@app.route('/consulta7', methods=['GET'])
def get_consulta7():
    datos = {
        'nombre': 'Juan',
        'apellido': 'Perez',
        'edad': 30
    }
    return jsonify(datos)

# Mostrar las ventas por mes de Inglaterra. Debe de mostrar el numero del mes y el monto.
@app.route('/consulta8', methods=['GET'])
def get_consulta8():
    datos = {
        'nombre': 'Juan',
        'apellido': 'Perez',
        'edad': 30
    }
    return jsonify(datos)

# Mostrar el mes con mas y menos ventas. Se debe de mostrar el numero de mes y monto. (Una sola consulta).
@app.route('/consulta9', methods=['GET'])
def get_consulta9():
    datos = {
        'nombre': 'Juan',
        'apellido': 'Perez',
        'edad': 30
    }
    return jsonify(datos)

# Mostrar las ventas de cada producto de la categoria deportes. Se debe de mostrar el id del producto, nombre y monto.
@app.route('/consulta10', methods=['GET'])
def get_consulta10():
    datos = {
        'nombre': 'Juan',
        'apellido': 'Perez',
        'edad': 30
    }
    return jsonify(datos)

@app.route('/crearmodelo', methods=['GET'])
def get_crear_modelo():
    cursor = db.cursor()
    print("Conexión exitosa")
    # Ejemplo de consulta para obtener datos agregados
    consulta = "SELECT * FROM categoria"
    cursor.execute(consulta)
    #resultado = cursor.fetchone()  # Obtiene la primera fila de resultados
    resultado = cursor.fetchall()  # Obtiene todos los resultados de la consulta

    # Convierte los resultados en un formato JSON y los devuelve
    resultado_obtenido = []
    for fila in resultado:
        resultado_obtenido.append({
            'id_categoria': fila[0],
            'nombre': fila[1],
        })
    cursor.close()  # Cerrar el cursor
    print(resultado_obtenido)
    return jsonify(resultado_obtenido)

@app.route('/cargarmodelo', methods=['GET'])
def get_cargar_modelo():
    cursor = db.cursor()
    try:
        # Abrir el archivo CSV y leer los datos
        with open('Categorias.csv', 'r') as csv_file:
            csv_reader  = csv.DictReader(csv_file, delimiter=';')
       
            for row in csv_reader:
                id_categoria = row['id_categoria']
                nombre = row['nombre']
                # Inserta los datos en la base de datos
                #cur = mysql.connection.cursor()
                cursor.execute("INSERT INTO categoria (id_categoria, nombre) VALUES (%s, %s)", (id_categoria, nombre))
                db.commit()
        return 'Datos insertados correctamente'

    except Exception as e:
        db.rollback()  # Revertir cualquier cambio si hay un error
        return f"Error al cargar datos: {str(e)}"
    finally:
        cursor.close()  # Cerrar el cursor
        db.close()  # Cerrar la conexión a la base de datos

@app.route('/eliminarmodelo', methods=['GET'])
def get_eliminar_modelo():
    datos = {
        'nombre': 'Juan',
        'apellido': 'Perez',
        'edad': 30
    }
    return jsonify(datos)

@app.route('/borrarinfodb', methods=['GET'])
def get_borrar_info_db():
    datos = {
        'nombre': 'Juan',
        'apellido': 'Perez',
        'edad': 30
    }
    return jsonify(datos)

if __name__ == '__main__':
    app.run(debug=True)