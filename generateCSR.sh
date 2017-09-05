#!/bin/bash
 
# if less than four arguments supplied, display usage
# path to key is optional for the case you want to use an existing key
 
if [ $# -le 4 ]
then
    echo "Usage: ./generateCSR.sh NL 'Noord-Holland' 'Amsterdam' 'Your Company B.V.' hostname [/path/to/key]"
    exit 1
fi
CSR_DETAILS=$(mktemp)
 
COUNTRY=${1}
STATE=${2}
LOCATION=${3}
ORGANIZATION=${4}
SERVERNAME=${5}
KEY=${6}
PREFIX=`echo -n ${SERVERNAME} | cut -f 1 -d '.'`
DOMAIN=`echo ${SERVERNAME} | sed -e "s/^www\.//"`
 
if [ "$PREFIX" = "www" ]
then
   DOMAINLINE="DNS.2 = ${DOMAIN}"
fi
 
cat > ${CSR_DETAILS} <<-EOF
[req]
default_bits = 4096
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn
 
[ dn ]
C=${COUNTRY}
ST=${STATE}
L=${LOCATION}
O=${ORGANIZATION}
CN=${SERVERNAME}
 
[ req_ext ]
subjectAltName = @alt_names
 
[ alt_names ]
DNS.1 = ${SERVERNAME}
${DOMAINLINE}
EOF
 
# Let's call openssl now by piping the newly created file in
if [ $# -eq 6 ]
then
  openssl req -new -sha256 -nodes -out ${SERVERNAME}.csr -key ${KEY} -config ${CSR_DETAILS}
else
  if [ -a ${SERVERNAME}.key ]
  then
    echo ${SERVERNAME}.key already exists, aborting
    exit 1
  fi
  openssl req -new -sha256 -nodes -out ${SERVERNAME}.csr -newkey rsa:4096 -keyout ${SERVERNAME}.key -config ${CSR_DETAILS}
  chmod 600 ${SERVERNAME}.key
fi
 
rm ${CSR_DETAILS}
 
openssl req -text -noout -verify -in ${SERVERNAME}.csr
