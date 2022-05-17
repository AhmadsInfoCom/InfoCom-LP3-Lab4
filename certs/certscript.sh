#IP-adresses:
ebbaIP=100.100.100.24
ahmadIP=100.100.100.23
markusIP=100.100.100.25

#Ports:
droneport=5000
buildport=5000
databaseport=5001
routeplannerport=5002

#Last two can be empty.
CAkeypass=realCA
exportpassword=
challengepassword=

#Note that / is not included in the end

serverfolder=servers
buildfolder=servers/build
routeplannerfolder=servers/routeplanner
databasefolder=servers/database

dronefolder=drones
drone1folder=drones/drone1
drone2folder=drones/drone2

CAfolder=CA

#The only things you need to change:
instance=drone2
folder=$drone2folder
domain=$markusIP:$droneport
CAfolder=$CAfolder



#Creates a key:
openssl genrsa -out $folder/$instance.key 2048

#Creates a certificate request:
openssl req -new \
-subj "/C=SE/ST=Scania/L=LUND/O=SDD/OU=$instance/CN=$domain" \
-key $folder/$instance.key \
-out $folder/$instance.csr \
-passout pass:$challengepassword

#Signs the request:
openssl x509 -req \
-in $folder/$instance.csr \
-out $folder/$instance.crt \
-CA $CAfolder/ca.crt \
-passin pass:$CAkeypass \
-CAkey $CAfolder/privkey.pem \
-CAcreateserial

#Packages signed cert into p12, for putting into web browser:
openssl pkcs12 -export \
-in $folder/$instance.crt \
-passout pass:$exportpassword \
-inkey $folder/$instance.key \
-out $folder/$instance.p12


