password=hejj
openssl req -x509 -subj "/C=SE/ST=Scania/L=LUND/O=SDD/OU=CA/CN=localhost" \
                         -out ca.crt -passout pass:$password
