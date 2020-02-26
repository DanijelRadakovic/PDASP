#!/bin/bash

if ! jq --version > /dev/null 2>&1 ; then
	echo "Please Install 'jq' https://stedolan.github.io/jq/ to execute this script"
	echo
	exit 1
fi


# Print the usage message
function printHelp () {
  echo "Usage: "
  echo "  ./testAPIs.sh -l golang|node"
  echo "    -l <language> - chaincode language (defaults to \"golang\")"
}
# Language defaults to "golang"
LANGUAGE="golang"

# Parse commandline args
while getopts "h?l:" opt; do
  case "$opt" in
    h|\?)
      printHelp
      exit 0
    ;;
    l)  LANGUAGE=$OPTARG
    ;;
  esac
done


echo "POST request Enroll on Org1  ..."
echo
ORG1_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Jim&orgName=Org1')
echo "$ORG1_TOKEN"
ORG1_TOKEN=$(echo "$ORG1_TOKEN" | jq ".token" | sed "s/\"//g")
echo
echo "ORG1 token is $ORG1_TOKEN"

echo "POST request Enroll on Org2 ..."
echo
ORG2_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Barry&orgName=Org2')
echo "$ORG2_TOKEN"
ORG2_TOKEN=$(echo "$ORG2_TOKEN" | jq ".token" | sed "s/\"//g")
echo
echo "ORG2 token is $ORG2_TOKEN"
echo










######################## TRANSFER 500 FROM USER2 TO USER1 MONEY ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (Transfer 500 from ur2 to ur1)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"transfer\",
  \"args\":[\"ur1\",\"ur2\",\"500\",\"n\"]
}")
echo "$VALUES"
echo


echo "GET query chaincode on peer1 of Org1 (Get user ur1)"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22ur1%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="


echo "GET query chaincode on peer1 of Org2(Get user ur1)"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org2.example.com&fcn=query&args=%5B%22ur1%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="


echo "GET query chaincode on peer1 of Org1 (Get user ur2)"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22ur2%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="


echo "GET query chaincode on peer1 of Org2 (Get user ur2)"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org2.example.com&fcn=query&args=%5B%22ur2%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="


echo "GET query chaincode on peer1 of Org1 (Get transaction tr10)"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22tr10%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="


######################## UNSUCCESSFUL TRANSFER 7000 FROM USER1 TO USER3 ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (Unsuccessful transfer 7000 from ur3 to ur2)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"transfer\",
  \"args\":[\"ur3\",\"ur1\",\"7000\",\"n\"]
}")
echo "$VALUES"
echo


######################## UNSUCCESSFUL TRANSFER 5000 FROM USER3 TO USER2 USING DEBT ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (Unsuccessful transfer 5000 from ur3 to ur2 using debt)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"transfer\",
  \"args\":[\"ur2\",\"ur3\",\"5000\",\"y\"]
}")
echo "$VALUES"
echo


######################## TRANSFER 3250 FROM USER3 TO USER2 USING DEBT ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (transfer 3250 from ur3 to ur2 using debt)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"transfer\",
  \"args\":[\"ur2\",\"ur3\",\"3250\",\"y\"]
}")
echo "$VALUES"
echo


echo "GET query chaincode on peer1 of Org1 (Get user ur2)"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22ur2%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="


echo "GET query chaincode on peer1 of Org2 (Get user ur2)"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org2.example.com&fcn=query&args=%5B%22ur2%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="


echo "GET query chaincode on peer1 of Org1 (Get user ur2)"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22ur2%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="


echo "GET query chaincode on peer1 of Org2 (Get user ur3)"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org2.example.com&fcn=query&args=%5B%22ur3%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="


echo "GET query chaincode on peer1 of Org1 (Get transaction tr11)"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22tr11%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="


######################## CREATE NEW BANK ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (Create new bank)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"createBank\",
  \"args\":[\"ErsteBank\",\"2004\",\"5000\",\"UK\",\"USA\",\"Poland\",\"Slovakia\",\"Denmark\"]
}")
echo "$VALUES"
echo


echo "GET query chaincode on peer1 of Org1 (Get bank bk3)"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22bk3%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="


######################## UNSUCCESSFUL CREATION OF NEW LOAN FOR USER5 BECAUSE AMOUNT IS TO BIG ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (Create new loan for ur5 that is to big)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"createLoan\",
  \"args\":[\"ur5\",\"25.02.2020.\",\"25.02.2021.\",\"0.02\",\"12\",\"3000\"]
}")
echo "$VALUES"
echo

######################## UNSUCCESSFUL CREATION OF NEW LOAN FOR USER1 BECAUSE IT ALTREDY HAS LOAN ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (Create new loan for ur1 that already has loan)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"createLoan\",
  \"args\":[\"ur1\",\"25.02.2020.\",\"25.02.2021.\",\"0.5\",\"1\",\"1000\"]
}")
echo "$VALUES"
echo


######################## CREATE NEW LOAN FOR USER5 ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (Create new loan for ur5)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"createLoan\",
  \"args\":[\"ur5\",\"25.02.2020.\",\"25.02.2021.\",\"0.5\",\"1\",\"1000\"]
}")
echo "$VALUES"
echo


echo "GET query chaincode on peer1 of Org1 (Get loan ln5)"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22ln5%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="


echo "GET query chaincode on peer1 of Org1 (Get user ur5)"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22ur5%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="


echo "GET query chaincode on peer1 of Org1 (Get bank bk2)"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22bk2%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="


echo "GET query chaincode on peer1 of Org1 (Get transacion tr12)"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22tr12%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="


######################## USER1 PAYS INTALLMENT ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (us1 pays installment amount 220)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"payInstallment\",
  \"args\":[\"ur1\",\"220\"]
}")
echo "$VALUES"
echo


echo "GET query chaincode on peer1 of Org1 (Get user ur1)"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22ur1%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="


echo "GET query chaincode on peer1 of Org1 (Get bank bk1)"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22bk1%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="


echo "GET query chaincode on peer1 of Org1 (Get transacion tr13)"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22tr13%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="


######################## UNSUCCESSFUL INSTALLMENT PAYMENT OF USER1 BECAUSE AMOUNT IS NOT CORRECT  ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (us1 pays installment amount 300)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"payInstallment\",
  \"args\":[\"ur1\",\"300\"]
}")
echo "$VALUES"
echo


######################## USER5 PAYS LAST INTALLMENT ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (us5 pays last installment amount 1500)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"payInstallment\",
  \"args\":[\"ur5\",\"1500\"]
}")
echo "$VALUES"
echo


echo "GET query chaincode on peer1 of Org1 (Get user ur5)"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22ur5%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="


echo "GET query chaincode on peer1 of Org1 (Get bank bk2)"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22bk2%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="


echo "GET query chaincode on peer1 of Org1 (Get transacion tr14)"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22tr14%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="


######################## UNSUCCESSFUL INSTALLMENT PAYMENT OF USER5 BECAUSE NO LOAN IS FOUND  ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (us5 pays installment of no loan)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"payInstallment\",
  \"args\":[\"ur5\",\"1500\"]
}")
echo "$VALUES"
echo


######################## CREATE NEW USER  ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (create new  user)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"createUser\",
  \"args\":[\"Jack\",\"Stallman\",\"jack@gmail.com\",\"bk1\",\"7000\"]
}")
echo "$VALUES"
echo


echo "GET query chaincode on peer1 of Org1 (Get user ur6)"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22ur6%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="


echo "GET query chaincode on peer1 of Org1 (Get bank bk1)"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22bk1%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="