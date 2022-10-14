#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

ORG=1
P0PORT=7051
CAPORT=7054
PEERPEM=organizations/peerOrganizations/org1.14.49.119.248/tlsca/tlsca.org1.14.49.119.248-cert.pem
CAPEM=organizations/peerOrganizations/org1.14.49.119.248/ca/ca.org1.14.49.119.248-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org1.14.49.119.248/connection-org1.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org1.14.49.119.248/connection-org1.yaml

ORG=2
P0PORT=9051
CAPORT=8054
PEERPEM=organizations/peerOrganizations/org2.14.49.119.248/tlsca/tlsca.org2.14.49.119.248-cert.pem
CAPEM=organizations/peerOrganizations/org2.14.49.119.248/ca/ca.org2.14.49.119.248-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org2.14.49.119.248/connection-org2.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org2.14.49.119.248/connection-org2.yaml

ORG=3
P0PORT=6051
CAPORT=6054
PEERPEM=organizations/peerOrganizations/org3.14.49.119.248/tlsca/tlsca.org3.14.49.119.248-cert.pem
CAPEM=organizations/peerOrganizations/org3.14.49.119.248/ca/ca.org3.14.49.119.248-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org3.14.49.119.248/connection-org3.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org3.14.49.119.248/connection-org3.yaml

ORG=4
P0PORT=5051
CAPORT=5054
PEERPEM=organizations/peerOrganizations/org4.14.49.119.248/tlsca/tlsca.org4.14.49.119.248-cert.pem
CAPEM=organizations/peerOrganizations/org4.14.49.119.248/ca/ca.org4.14.49.119.248-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org4.14.49.119.248/connection-org4.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org4.14.49.119.248/connection-org4.yaml