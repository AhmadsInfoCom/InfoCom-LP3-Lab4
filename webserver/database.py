from flask import Flask, request
from flask_cors import CORS
import redis
import json
from werkzeug import serving
import ssl

HTTPS_ENABLED = True
VERIFY_USER=False

SVR_CRT="../certs/servers/database/database.crt"
SVR_KEY="../certs/servers/database/database.key"
CA_CRT="../certs/CA/ca.crt"

app = Flask(__name__)
CORS(app)

# change this to connect to your redis server
# ===============================================
redis_server = redis.Redis(host='localhost', port=6379, decode_responses=True, charset="unicode_escape", password='SDD')    # Gissar på detta, vi kör ju det här skriptet på localhost (server pi). Stod från början: redis.Redis("REDIS_SERVER", decode_responses=True, charset="unicode_escape")
# ===============================================

@app.route('/drone', methods=['POST'])
def drone():
    drone = request.get_json()          #hämtar drone_info som postats av simulator på denna URL
    droneIP = request.remote_addr
    droneID = drone['id']
    drone_longitude = drone['longitude']
    drone_latitude = drone['latitude']
    drone_status = drone['status']
    # Get the information of the drone in the request, and update the information in Redis database
    # Data that need to be stored in the database: 
    # Drone ID, logitude of the drone, latitude of the drone, drone's IP address, the status of the drone
    # Note that you need to store the metioned infomation for all drones in Redis, think carefully how to store them
    # =========================================================================================
    
    
    #stod inget här innan, jag skrev allt inom den här rutan. Vi måste fråga hur man ska tänka här nere med att sätta värdena i redis för jag är osäker på det. 
    
    #Kanske:
    #Gör en if-sats, t.ex. if(droneID = drone1) så ska i = 1, och formattera strängen därefter, så drone{i}: t.ex. redis.server.set('drone{i}_status', drone_status),  för: ID, IP, status, longitude, latitude
    
    drone_list = [droneIP, drone_status, drone_longitude, drone_latitude]   #droneID isn't needed in the list, right?
    json_drone_list = json.dumps(drone_list)          #konverterar listan till en sträng: https://pythonexamples.org/python-list-to-json/
    redis_server.set(droneID, json_drone_list)        #lägger in strängen i redis_server


    """
    if(droneID == "drone1"):
        drone1_list = [droneIP, drone_status, drone_longitude, drone_latitude]   #droneID isn't needed in the list, right?
        json_drone1_list = json.dumps(drone1_list)          #konverterar listan till en sträng: https://pythonexamples.org/python-list-to-json/
        redis_server.set(droneID, json_drone1_list)        #lägger in strängen i redis_server
    else:
        drone2_list = [droneIP, drone_status, drone_longitude, drone_latitude]   #droneID isn't needed in the list, right?
        json_drone2_list = json.dumps(drone2_list)
        redis_server.set(droneID, json_drone2_list)        #lägger in strängen i redis_server
    """
    #json.loads(redis_server.get(droneID))   
    
    """
    pickle_drone_list = pickle.dumps(drone_list)
    redis_server.set(droneID, pickle_drone_list)
    #pickle.loads(droneID, pickle_drone_list)
    """

    #annars lpush, zadd, vad är det? 
    

     # =======================================================================================
    return 'Get data'

if __name__ == "__main__":
    context = None
    print("Main is run.")
    filecreationdebugging = open("/home/debuggingtestfile.txt", "x")
    if HTTPS_ENABLED:
        context = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2) # alternativt:   ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
        #print("HTTPS is enabled, i.e. server needs to authenticate.")
    if VERIFY_USER:
        context.verify_mode = ssl.CERT_REQUIRED
        context.load_verify_locations(CA_CRT)   #Vi litar på klienter med certifikat signerat av CA.
        print("Two-way HTTPS is enabled, i.e. client needs to authenticate as well.")
    try:
        context.load_cert_chain(SVR_CERT, SVR_KEY)
    except:
        sys.exit("Error starting flask server, idk what we've done")
    #serving.run_simple("0.0.0.0", 5000, app, ssl_context=context)
    app.run(debug=True, host='0.0.0.0', port='5000', ssl_context=context)