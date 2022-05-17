password=fakeCA
openssl req -x509 \
-subj "/C=SE/ST=Scania/L=LUND/O=TotallyNotHackers/OU=HackingUnit/CN=localhost" \
-out fakeca.crt \
-passout pass:$password
