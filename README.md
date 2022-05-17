# LP4 Drone Project - Lab 4

This is the specialization project. To run the program, do the following:



Intall the requied Python packages, redis is added in the list
```
pip3 install -r requirements.txt
```

## On the Server Pi:
Go to `/webserver`, start your Redis server and run the two flask servers:





1. On Terminal 1, check your redis.conf file and make sure requirepass is uncommented and set to SDD or whatever is in the build-, database-, and route_planner-code when they specify a password for redis,
Then start your redis server with the configuration file by typing:
```
redis-server /home/pi/redis-stable/redis.conf (or whatever the path to redis conf is).
```






2. On Terminal 2, run `database.py`
```
export FLASK_APP=database.py
export FLASK_ENV=development
flask run --port=5001 --host 0.0.0.0
```






3. On Terminal 3, run `build.py` preferably like below, or through: 
```
export FLASK_APP=build.py
export FLASK_ENV=development
python3 build.py
```
otherwise, for https:
```
flask run --host 0.0.0.0 --cert=(relative path to cert) --key=(relative path to key)
```




4. On Terminal 4, run `route_planner.py`
```
export FLASK_APP=route_planner.py
export FLASK_ENV=development
flask run --port=5002 --host 0.0.0.0
```




## On the Drone Pis:
You need to install the Python packages in the requirements if you haven't done any. 

Go to `/pi`, run `drone.py`
```
export FLASK_APP=drone.py
export FLASK_ENV=development
flask run --host 0.0.0.0
```

Note: Don't use `python3 build.py` to run the servers, since this does not porvide all the functionalities required by the application.

