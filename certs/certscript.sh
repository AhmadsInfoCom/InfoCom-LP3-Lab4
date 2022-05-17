#IP-adresses:
ebbaIP=100.100.100.24
ahmadIP=100.100.100.23
markusIP=100.100.100.25

#Ports:
drone1port=5000
drone2port=5000
buildport=5000
databaseport=5001
routeplannerport=5002

#Last two can be empty.
CAkeypass=realCA
exportpassword=
challengepassword=

#Note that / is not included in the end

serverfolderpath=servers
dronefolderpath=drones
CAfolder=CA


#The only things you need to change:
instance=drone2
port=$drone2port
IP=$markusIP
folderpath=$dronefolderpath

#If you move the shellscript, don't forget to update the folder names above, as well as the format on "folder" above here.

#No need to change this:
domain=$IP:$port
folder=$folderpath/$instance
#SAN=DNS:localhost, IP:localhost, IP:0.0.0.0, IP:0.0.0.0$port, IP:$IP$port




#Creates a key:
openssl genrsa -out $folder/$instance.key 2048

#Creates a certificate request:
openssl req -new \
-subj "/C=SE/ST=Scania/L=LUND/O=SDD/OU=$instance/CN=$domain" \
-addext "subjectAltName = DNS:localhost" \
-key $folder/$instance.key \
-out $folder/$instance.csr \
-passout pass:$challengepassword
#OBS! För subjectAltName, lägg till:
# -addext "subjectAltName = IP:0.0.0.0" \
# -addext "subjectAltName = IP:$IP" \
# -addext "subjectAltName = IP:0.0.0.0:$port" \
# -addext "subjectAltName = IP:$IP:$port \
# efter subj, för alla altNames du vill ha. Men då behöver du göra om filerna till pem, eftersom den klagar när den ska göra till pks annars:
# "no certificate matches private key"
# OBS! dessutom klagade den med "bad ip adress" när vi skrev med porten som subjectAltName (testade nämligen alla), både 0.0.0.0 och statiska IP-adressen....
# ...så kan hända att du får skita i de sista två också.

#Signs the request:
openssl x509 -req \
-in $folder/$instance.csr \
-out $folder/$instance.crt \
-CA $CAfolder/ca.crt \
-passin pass:$CAkeypass \
-CAkey $CAfolder/privkey.pem \
-CAcreateserial

echo "OK. Now it's time for the pkcs12 export, be wary of key-crt matching problems due to subjectAltName."

#Packages signed cert into p12, for putting into web browser:
openssl pkcs12 -export \
-in $folder/$instance.crt \
-passout pass:$exportpassword \
-inkey $folder/$instance.key \
-out $folder/$instance.p12

echo "So... if you got this with no error message in between, you're good."

