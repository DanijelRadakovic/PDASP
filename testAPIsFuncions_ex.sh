#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

jq --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Please Install 'jq' https://stedolan.github.io/jq/ to execute this script"
	echo
	exit 1
fi

starttime=$(date +%s)

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

##set chaincode path
function setChaincodePath(){
	LANGUAGE=`echo "$LANGUAGE" | tr '[:upper:]' '[:lower:]'`
	case "$LANGUAGE" in
		"golang")
		CC_SRC_PATH="github.com/example_cc/go"
		;;
		"node")
		CC_SRC_PATH="$PWD/artifacts/src/github.com/example_cc/node"
		;;
		*) printf "\n ------ Language $LANGUAGE is not supported yet ------\n"$
		exit 1
	esac
}

setChaincodePath

echo "POST request Enroll on Org1  ..."
echo
ORG1_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Jim&orgName=Org1')
echo $ORG1_TOKEN
ORG1_TOKEN=$(echo $ORG1_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG1 token is $ORG1_TOKEN"

echo "POST request Enroll on Org2 ..."
echo
ORG2_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Barry&orgName=Org2')
echo $ORG2_TOKEN
ORG2_TOKEN=$(echo $ORG2_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG2 token is $ORG2_TOKEN"

echo "POST request Enroll on Org3 ..."
echo
ORG3_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Barry1&orgName=Org3')
echo $ORG3_TOKEN
ORG3_TOKEN=$(echo $ORG3_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG3 token is $ORG3_TOKEN"
echo
echo "====================================================================================="
echo
echo "GET query chaincode on peer1 of Org1"
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22u100%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo

echo
echo "GET query chaincode on peer1 of Org1"
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22u101%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo

echo
echo "GET query chaincode on peer1 of Org1"
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22u102%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="
echo
echo "POST invoke chaincode on peers of Org1 and Org2 (Add new user)"
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\",\"peer0.org3.example.com\"],
  \"fcn\":\"addUser\",
  \"args\":[\"Milos\",\"Miletic\",\"milos@gmail.com\",\"12000\"]
}")
echo $VALUES
# Assign previous invoke transaction id  to TRX_ID
MESSAGE=$(echo $VALUES | jq -r ".message")
TRX_ID=${MESSAGE#*ID: }
echo

echo "GET query chaincode on peer1 of Org1"
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22u103%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="
echo
echo "GET query chaincode on peer1 of Org1"
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22b0%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo

echo
echo "GET query chaincode on peer1 of Org1"
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22b1%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="
echo
echo "GET query chaincode on peer1 of Org1"
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22t0%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo

echo
echo "GET query chaincode on peer1 of Org1"
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22t1%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="
echo

echo "POST invoke chaincode on peers of Org1 and Org2 (Add new transaction)"
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\",\"peer0.org3.example.com\"],
  \"fcn\":\"addTransaction\",
  \"args\":[\"u101\",\"u102\",\"100\",\"0\"]
}")
echo $VALUES
# Assign previous invoke transaction id  to TRX_ID
MESSAGE=$(echo $VALUES | jq -r ".message")
TRX_ID=${MESSAGE#*ID: }
echo

echo "GET query chaincode on peer1 of Org1"
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22t2%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo

echo
echo "GET query chaincode on peer1 of Org1"
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22u101%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo

echo
echo "GET query chaincode on peer1 of Org1"
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22u102%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo

echo
echo "POST invoke chaincode on peers of Org1 and Org2 (Add new transaction)"
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\",\"peer0.org3.example.com\"],
  \"fcn\":\"addTransaction\",
  \"args\":[\"u201\",\"u102\",\"100\",\"0\"]
}")
echo $VALUES
# Assign previous invoke transaction id  to TRX_ID
MESSAGE=$(echo $VALUES | jq -r ".message")
TRX_ID=${MESSAGE#*ID: }
echo

echo "POST invoke chaincode on peers of Org1 and Org2 (Add new transaction)"
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\",\"peer0.org3.example.com\"],
  \"fcn\":\"addTransaction\",
  \"args\":[\"u101\",\"u202\",\"100\",\"0\"]
}")
echo $VALUES
# Assign previous invoke transaction id  to TRX_ID
MESSAGE=$(echo $VALUES | jq -r ".message")
TRX_ID=${MESSAGE#*ID: }
echo

echo "POST invoke chaincode on peers of Org1 and Org2 (Add new transaction)"
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\",\"peer0.org3.example.com\"],
  \"fcn\":\"addTransaction\",
  \"args\":[\"u101\",\"u102\",\"100000000\",\"0\"]
}")
echo $VALUES
# Assign previous invoke transaction id  to TRX_ID
MESSAGE=$(echo $VALUES | jq -r ".message")
TRX_ID=${MESSAGE#*ID: }
echo

echo "POST invoke chaincode on peers of Org1 and Org2 (Add new transaction)"
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\",\"peer0.org3.example.com\"],
  \"fcn\":\"addTransaction\",
  \"args\":[\"u101\",\"u102\",\"-1\",\"0\"]
}")
echo $VALUES
# Assign previous invoke transaction id  to TRX_ID
MESSAGE=$(echo $VALUES | jq -r ".message")
TRX_ID=${MESSAGE#*ID: }
echo

echo "POST invoke chaincode on peers of Org1 and Org2 (Add new transaction)"
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\",\"peer0.org3.example.com\"],
  \"fcn\":\"addTransaction\",
  \"args\":[\"u102\",\"u101\",\"550\",\"1\"]
}")
echo $VALUES
# Assign previous invoke transaction id  to TRX_ID
MESSAGE=$(echo $VALUES | jq -r ".message")
TRX_ID=${MESSAGE#*ID: }
echo

echo "POST invoke chaincode on peers of Org1 and Org2 (Add new transaction)"
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\",\"peer0.org3.example.com\"],
  \"fcn\":\"addTransaction\",
  \"args\":[\"u102\",\"u101\",\"450\",\"1\"]
}")
echo $VALUES
# Assign previous invoke transaction id  to TRX_ID
MESSAGE=$(echo $VALUES | jq -r ".message")
TRX_ID=${MESSAGE#*ID: }
echo

echo
echo "GET query chaincode on peer1 of Org1"
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22t3%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo

echo
echo "GET query chaincode on peer1 of Org1"
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22u101%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo

echo
echo "GET query chaincode on peer1 of Org1"
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22u102%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo

echo
echo "POST invoke chaincode on peers of Org1 and Org2 (Add new transaction)"
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\",\"peer0.org3.example.com\"],
  \"fcn\":\"addTransaction\",
  \"args\":[\"u102\",\"u101\",\"450\",\"1\"]
}")
echo $VALUES
# Assign previous invoke transaction id  to TRX_ID
MESSAGE=$(echo $VALUES | jq -r ".message")
TRX_ID=${MESSAGE#*ID: }
echo
echo "====================================================================================="

echo
echo "GET query chaincode on peer1 of Org1"
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22c0%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo

echo
echo "GET query chaincode on peer1 of Org1"
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22c1%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo

echo
echo "POST invoke chaincode on peers of Org1 and Org2 (Add new credit)"
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\",\"peer0.org3.example.com\"],
  \"fcn\":\"addCredit\",
  \"args\":[\"3\",\"5\",\"12000\",\"u101\"]
}")
echo $VALUES
# Assign previous invoke transaction id  to TRX_ID
MESSAGE=$(echo $VALUES | jq -r ".message")
TRX_ID=${MESSAGE#*ID: }
echo

echo
echo "POST invoke chaincode on peers of Org1 and Org2 (Add new credit)"
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\",\"peer0.org3.example.com\"],
  \"fcn\":\"addCredit\",
  \"args\":[\"3\",\"5\",\"6000\",\"u101\"]
}")
echo $VALUES
# Assign previous invoke transaction id  to TRX_ID
MESSAGE=$(echo $VALUES | jq -r ".message")
TRX_ID=${MESSAGE#*ID: }
echo

echo
echo "GET query chaincode on peer1 of Org1"
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22c2%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo

echo
echo "POST invoke chaincode on peers of Org1 and Org2 (Add new credit)"
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\",\"peer0.org3.example.com\"],
  \"fcn\":\"addCredit\",
  \"args\":[\"3\",\"5\",\"8000\",\"u101\"]
}")
echo $VALUES
# Assign previous invoke transaction id  to TRX_ID
MESSAGE=$(echo $VALUES | jq -r ".message")
TRX_ID=${MESSAGE#*ID: }
echo

echo
echo "POST invoke chaincode on peers of Org1 and Org2 (Pay credit)"
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\",\"peer0.org3.example.com\"],
  \"fcn\":\"payCredit\",
  \"args\":[\"u101\",\"c2\"]
}")
echo $VALUES
# Assign previous invoke transaction id  to TRX_ID
MESSAGE=$(echo $VALUES | jq -r ".message")
TRX_ID=${MESSAGE#*ID: }
echo

echo
echo "GET query chaincode on peer1 of Org1"
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22c2%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo

echo
echo "GET query chaincode on peer1 of Org1"
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22u101%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo

echo
echo "POST invoke chaincode on peers of Org1 and Org2 (Pay credit)"
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\",\"peer0.org3.example.com\"],
  \"fcn\":\"payCredit\",
  \"args\":[\"u101\",\"c2\"]
}")
echo $VALUES
# Assign previous invoke transaction id  to TRX_ID
MESSAGE=$(echo $VALUES | jq -r ".message")
TRX_ID=${MESSAGE#*ID: }
echo

echo
echo "GET query chaincode on peer1 of Org1"
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22c2%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo

echo
echo "GET query chaincode on peer1 of Org1"
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22u101%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo

echo
echo "POST invoke chaincode on peers of Org1 and Org2 (Pay credit)"
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\",\"peer0.org3.example.com\"],
  \"fcn\":\"payCredit\",
  \"args\":[\"u101\",\"c2\"]
}")
echo $VALUES
# Assign previous invoke transaction id  to TRX_ID
MESSAGE=$(echo $VALUES | jq -r ".message")
TRX_ID=${MESSAGE#*ID: }
echo

echo
echo "GET query chaincode on peer1 of Org1"
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22c2%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo

echo
echo "GET query chaincode on peer1 of Org1"
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22u101%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo

echo
echo "POST invoke chaincode on peers of Org1 and Org2 (Pay credit)"
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\",\"peer0.org3.example.com\"],
  \"fcn\":\"payCredit\",
  \"args\":[\"u101\",\"c2\"]
}")
echo $VALUES
# Assign previous invoke transaction id  to TRX_ID
MESSAGE=$(echo $VALUES | jq -r ".message")
TRX_ID=${MESSAGE#*ID: }
echo

echo
echo "POST invoke chaincode on peers of Org1 and Org2 (Add new credit)"
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\",\"peer0.org3.example.com\"],
  \"fcn\":\"addCredit\",
  \"args\":[\"3\",\"5\",\"5000\",\"u101\"]
}")
echo $VALUES
# Assign previous invoke transaction id  to TRX_ID
MESSAGE=$(echo $VALUES | jq -r ".message")
TRX_ID=${MESSAGE#*ID: }
echo

echo
echo "GET query chaincode on peer1 of Org1"
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22c3%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
