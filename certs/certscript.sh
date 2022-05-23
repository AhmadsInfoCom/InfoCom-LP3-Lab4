#CAUTION! If you move this shellscript, don't forget to update the folder names below, as well as the format on the "folder"-variable, if needed. 



#IP-adresses:
ebbaIP=100.100.100.24
ahmadIP=100.100.100.23
markusIP=100.100.100.25
browserIP=0.0.0.0

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

#Note that / is not included in the end:
serverfolderpath=servers
dronefolderpath=drones
browserfolderpath=browser
CAfolderpath=CA

#The only things you need to change:
instance=database
port=$databaseport
IP=$ebbaIP
folderpath=$serverfolderpath

#No need to change this:
domain=$IP:$port
folder=$folderpath/$instance
#SAN=DNS:localhost, IP:localhost, IP:0.0.0.0, IP:0.0.0.0$port, IP:$IP$port
 
 


#OM FORTF BROWSERN KLAGAR:
#ska du kommentera bort subj alt names i själva csr-skapandet? 
#testa ändra common name till bara ip, istället för ip+port (isf kan du bara ta bort "domain" lol)
#^BEHÖVDES EJ, FUNKADE ÄNDÅ :-)

#Men ev. problem att webb-browser promptar för klientcertifikat, det gör att route_planner inte funkar bra. Hur få bort det?

#Dessa löser problemet:
# https://stackoverflow.com/questions/30769142/firefox-automatically-choose-certificate-without-ui-dialog 
# https://stackoverflow.com/questions/27864553/how-can-i-choose-a-different-client-certificate-in-firefox 

#Dessa är extra, just in case det behövs:
# https://stackoverflow.com/questions/6108091/is-it-possible-to-automatically-select-correct-client-side-certificate
# https://stackoverflow.com/questions/40653785/how-to-stop-chromes-select-a-certificate-window 
# https://stackoverflow.com/questions/33098570/how-to-disable-client-certificate-prompt-in-google-chrome
# https://stackoverflow.com/questions/1331722/client-certificates-and-firefox 
# https://serverfault.com/questions/1068169/how-to-make-firefox-prompt-for-windowss-own-certificate-stores-client-certific
# https://blogs.sap.com/2014/01/30/avoid-certification-selection-popup-in-chrome/  
# https://techcommunity.microsoft.com/t5/discussions/is-there-a-way-to-set-autoselectcertificateforurls-policy-on/m-p/2256289 
# https://gist.github.com/IngussNeilands/3bbbb7d78954c85e2e988cf3bfec7caa 
# https://docs.microsoft.com/en-us/answers/questions/570440/the-edge-chromium-39autoselectcertificateforurls39.html
# https://techcommunity.microsoft.com/t5/enterprise/how-do-i-setup-autocertificateselectforurls-in-the-registry-to/m-p/1149019







#Creates a key:
openssl genrsa -out $folder/$instance.key 2048




#Creates a .conf file that is sent in to csr and signing, so that these extensions are used when signing request (otherwise the signing will apparently not include subject alternative name):
cat > $folder/$instance-csr.conf << HERE-TAGWORD
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C = SE
ST = Scania
L = Lund
O = Secure Drone Deliveries
OU = $instance 
CN = $domain

[v3_req]
keyUsage = nonRepudiation,digitalSignature,keyEncipherment,dataEncipherment
extendedKeyUsage = serverAuth,clientAuth
subjectAltName = @alt_names

[alt_names]
IP.1 = $IP 
IP.2 = 0.0.0.0
DNS.1 = localhost
DNS.2 = $IP
DNS.4 = $IP:$port
DNS.3 = 0.0.0.0:$port
HERE-TAGWORD




#Creates a certificate request:
openssl req -new \
-subj "/C=SE/ST=Scania/L=LUND/O=Secure Drone Deliveries/OU=$instance/CN=$domain" \
-addext "subjectAltName = IP:0.0.0.0" \
-key $folder/$instance.key \
-out $folder/$instance.csr \
-passout pass:$challengepassword \
-config $folder/$instance-csr.conf    #för att skicka med config-filen, se ovan.



#GAMMALT PROBLEM (innan användning av -extfile):
#OBS! just nu kommer subjAltName ändå inte med för du har inte specificerat subject alternative names när du signerar, så det kommer inte med i out-filen. Kolla grn för en länk om det
# ellre här: https://stackoverflow.com/questions/30977264/subject-alternative-name-not-present-in-certificate
#där står det hur du ska göra för att ha med SAN. Det du ska göra är att sätta på extensions under signing, och anvcända dig av en -extfile för att få med flera subjectAltNames.
#OBS! om du har flera addext subjectAltName med -addext (dvs utan att köra en -extfil), så behöver du göra om filerna till pem, eftersom den klagar när den ska göra till pks annars:
# "no certificate matches private key". Men eftersom du använde ext-file nu så behöver du inte göra det!



#Signs the request:
openssl x509 -req \
-in $folder/$instance.csr \
-out $folder/$instance.crt \
-CAkey $CAfolderpath/privkey.pem \
-CA $CAfolderpath/ca.crt \
-passin pass:$CAkeypass \
-extfile $folder/$instance-csr.conf \
-extensions v3_req \
-CAcreateserial

#Lite förklaring av det ovan!
#-extensions v3_req      #måste ha extensions för subject alternative names
#-extfile $folder/$instance-csr.conf    #in-fil för alla subject alternative names och dylikt
#-CAcreateserial #skapar en serial number fil för att hålla reda på hur många som signats, egentligen ska den bara skapas första gången sen ska allt sparas i den men kvittar nu
# OBS! dessutom klagade den med "bad ip adress" när vi skrev med porten som subjectAltName, både 0.0.0.0 och statiska IP-adressen. Därav är de lagda som DNS. Men hade IP+port som Common Name.




echo "OK. Now it's time for the pkcs12 export, be wary of key-crt matching problems due to subjectAltName."

#Packages signed cert into p12, for putting into web browser:
openssl pkcs12 -export \
-in $folder/$instance.crt \
-passout pass:$exportpassword \
-inkey $folder/$instance.key \
-out $folder/$instance.p12

echo "So... if you got this with no error message in between, you're good. It means the pkcs12 export happened successfully!"

