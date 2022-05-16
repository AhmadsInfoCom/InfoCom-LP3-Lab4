from os import fdopen
from flask import Flask, render_template, request
from flask.json import jsonify
from flask_socketio import SocketIO, emit
from flask_cors import CORS
import time
import redis
import pickle
import json
from werkzeug import serving
import ssl

#from webserver.database import drone

HTTPS_ENABLED = True
VERIFY_USER=False,

API_CRT="servers.crt"
API_KEY="servers.key"
API_CA_T="ca.crt"

app = Flask(__name__)
CORS(app)
app.secret_key = 'dljsaklqk24e21cjn!Ew@@dsa5'

# change this so that you can connect to your redis server
# ===============================================
redis_server = redis.Redis(host='localhost', port=6379, decode_responses=True, charset="unicode_escape", password='SDD')    # Gissar på detta, vi kör ju det här skriptet på localhost (server pi). Stod från början: redis.Redis("REDIS_SERVER", decode_responses=True, charset="unicode_escape")
# ===============================================

#strict redis?
#utf-8


# Translate OSM coordinate (longitude, latitude) to SVG coordinates (x,y).
# Input coords_osm is a tuple (longitude, latitude).
def translate(coords_osm):
    x_osm_lim = (13.143390664, 13.257501336)
    y_osm_lim = (55.678138854000004, 55.734680845999996)

    x_svg_lim = (212.155699, 968.644301)
    y_svg_lim = (103.68, 768.96)

    x_osm = coords_osm[0]
    y_osm = coords_osm[1]

    x_ratio = (x_svg_lim[1] - x_svg_lim[0]) / (x_osm_lim[1] - x_osm_lim[0])
    y_ratio = (y_svg_lim[1] - y_svg_lim[0]) / (y_osm_lim[1] - y_osm_lim[0])
    x_svg = x_ratio * (x_osm - x_osm_lim[0]) + x_svg_lim[0]
    y_svg = y_ratio * (y_osm_lim[1] - y_osm) + y_svg_lim[0]

    return x_svg, y_svg

@app.route('/', methods=['GET'])
def map():
    return render_template('index.html')

@app.route('/get_drones', methods=['GET'])
def get_drones():
    #=============================================================================================================================================
    # Get the information of all the drones from redis server and update the dictionary `drone_dict' to create the response 
    # drone_dict should have the following format:
    # e.g if there are two drones in the system with IDs: DRONE1 and DRONE2
    # drone_dict = {'DRONE_1':{'longitude': drone1_logitude_svg, 'latitude': drone1_logitude_svg, 'status': drone1_status},
    #               'DRONE_2': {'longitude': drone2_logitude_svg, 'latitude': drone2_logitude_svg, 'status': drone2_status}
    #              }
    # use function translate() to covert the coodirnates to svg coordinates
    #=============================================================================================================================================
    
    drone_dict = dict()
    for key in redis_server.scan_iter():
        drone_array = json.loads(redis_server.get(key)) #.decode() borde inte behövas, vi har satt decode_respone=true
        print(json.loads(redis_server.get(key)))
        long, lat = translate((drone_array[2], drone_array[3]))
        drone = {key: {'longitude': long, 'latitude': lat, 'status': drone_array[1]}}
        drone_dict.update(drone) 
    
    '''
    drone1array = pickle.loads(redis_server.get('drone1')) #.decode()
    drone2array = pickle.loads(redis_server.get('drone2'))  #.decode()
    '''
                                                                                                                       
    return jsonify(drone_dict)

if __name__ == "__main__":
    context = None
    if HTTPS_ENABLED:
        context = ssl.SSLContext(ssl.PROTOCOL_TLSv1_3)
        if VERIFY_USER:
            context.verify_mode = ssl.CERT_REQUIRED
            context.load_verify_locations("../certs/CA/ca.crt")   #Vi litar på klienter med certifikat signerat av CA.
    try:
        context.load_cert_chain('servers.crt', 'servers.key')
        sys.exit("Error starting flask server. " + "Missing cert or key.".format(e))
    serving.run_simple("0.0.0.0", 5000, app, ssl_context=context)
    #app.run(debug=True, host='0.0.0.0', port='5000')