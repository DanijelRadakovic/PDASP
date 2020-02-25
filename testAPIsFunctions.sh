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
echo












echo "POST invoke chaincode on peers of Org1 and Org2 (Add new conference)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"addConference\",
  \"args\":[\"DSC 5.0\",\"Belgrade\",\"20.11.2019.\"]
}")
echo $VALUES
# Assign previous invoke transaction id  to TRX_ID
MESSAGE=$(echo $VALUES | jq -r ".message")
TRX_ID=${MESSAGE#*ID: }
echo


echo "GET query chaincode on peer1 of Org1"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22c1%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="






echo "POST invoke chaincode on peers of Org1 and Org2 (Add new tutor)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"addTutor\",
  \"args\":[\"Milos\",\"Miletic\"]
}")
echo $VALUES
# Assign previous invoke transaction id  to TRX_ID
MESSAGE=$(echo $VALUES | jq -r ".message")
TRX_ID=${MESSAGE#*ID: }
echo

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
echo $VALUES
# Assign previous invoke transaction id  to TRX_ID
MESSAGE=$(echo $VALUES | jq -r ".message")
TRX_ID=${MESSAGE#*ID: }
echo


echo "GET query chaincode on peer1 of Org1 (Get user ur1)"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22ur1%22%5D" \
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


echo "GET query chaincode on peer1 of Org1 (Get transaction tr5)"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22tr5%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="


echo "POST invoke chaincode on peers of Org1 and Org2 (Unsuccessful transfer 3500 from ur3 to ur2 using debt)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"transfer\",
  \"args\":[\"ur2\",\"ur3\",\"3500\",\"y\"]
}")
echo $VALUES
# Assign previous invoke transaction id  to TRX_ID
MESSAGE=$(echo $VALUES | jq -r ".message")
TRX_ID=${MESSAGE#*ID: }
echo


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
echo $VALUES
# Assign previous invoke transaction id  to TRX_ID
MESSAGE=$(echo $VALUES | jq -r ".message")
TRX_ID=${MESSAGE#*ID: }
echo


echo "GET query chaincode on peer1 of Org1 (Get user ur2)"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22ur2%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="


echo "GET query chaincode on peer1 of Org1 (Get user ur2)"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22ur3%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="


echo "GET query chaincode on peer1 of Org1 (Get transaction tr6)"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22tr6%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo "====================================================================================="


# echo "GET query chaincode on peer1 of Org1"
# echo
# curl -s -X GET \
#   "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22tu4%22%5D" \
#   -H "authorization: Bearer $ORG1_TOKEN" \
#   -H "content-type: application/json"
# echo
# echo "====================================================================================="







# echo "POST invoke chaincode on peers of Org1 and Org2 (Add new tutorial)"
# echo
# VALUES=$(curl -s -X POST \
#   http://localhost:4000/channels/mychannel/chaincodes/mycc \
#   -H "authorization: Bearer $ORG1_TOKEN" \
#   -H "content-type: application/json" \
#   -d "{
#   \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
#   \"fcn\":\"addTutorial\",
#   \"args\":[\"Hadoop tutorial\",\"tu1\",\"tu4\"]
# }")
# echo $VALUES
# # Assign previous invoke transaction id  to TRX_ID
# MESSAGE=$(echo $VALUES | jq -r ".message")
# TRX_ID=${MESSAGE#*ID: }
# echo

# echo "GET query chaincode on peer1 of Org1"
# echo
# curl -s -X GET \
#   "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22t3%22%5D" \
#   -H "authorization: Bearer $ORG1_TOKEN" \
#   -H "content-type: application/json"
# echo

# echo "====================================================================================="






# echo "POST invoke chaincode on peers of Org1 and Org2 (Add new tutor to existing tutorial)"
# echo
# VALUES=$(curl -s -X POST \
#   http://localhost:4000/channels/mychannel/chaincodes/mycc \
#   -H "authorization: Bearer $ORG1_TOKEN" \
#   -H "content-type: application/json" \
#   -d "{
#   \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
#   \"fcn\":\"addTutorToTutorial\",
#   \"args\":[\"t1\",\"tu4\"]
# }")
# echo $VALUES
# # Assign previous invoke transaction id  to TRX_ID
# MESSAGE=$(echo $VALUES | jq -r ".message")
# TRX_ID=${MESSAGE#*ID: }
# echo


# echo "GET query chaincode on peer1 of Org1"
# echo
# curl -s -X GET \
#   "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22t1%22%5D" \
#   -H "authorization: Bearer $ORG1_TOKEN" \
#   -H "content-type: application/json"
# echo
# echo "====================================================================================="





# echo "POST invoke chaincode on peers of Org1 and Org2 (Add new tutor to existing tutorial - error)"
# echo
# VALUES=$(curl -s -X POST \
#   http://localhost:4000/channels/mychannel/chaincodes/mycc \
#   -H "authorization: Bearer $ORG1_TOKEN" \
#   -H "content-type: application/json" \
#   -d "{
#   \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
#   \"fcn\":\"addTutorToTutorial\",
#   \"args\":[\"t1\",\"tu10\"]
# }")
# echo $VALUES
# # Assign previous invoke transaction id  to TRX_ID
# MESSAGE=$(echo $VALUES | jq -r ".message")
# TRX_ID=${MESSAGE#*ID: }
# echo


# echo "GET query chaincode on peer1 of Org1"
# echo
# curl -s -X GET \
#   "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22t1%22%5D" \
#   -H "authorization: Bearer $ORG1_TOKEN" \
#   -H "content-type: application/json"
# echo
# echo "====================================================================================="




# echo "POST invoke chaincode on peers of Org1 and Org2 (Add new tutor to existing tutorial - error)"
# echo
# VALUES=$(curl -s -X POST \
#   http://localhost:4000/channels/mychannel/chaincodes/mycc \
#   -H "authorization: Bearer $ORG1_TOKEN" \
#   -H "content-type: application/json" \
#   -d "{
#   \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
#   \"fcn\":\"addTutorToTutorial\",
#   \"args\":[\"t1\",\"tu2\"]
# }")
# echo $VALUES
# # Assign previous invoke transaction id  to TRX_ID
# MESSAGE=$(echo $VALUES | jq -r ".message")
# TRX_ID=${MESSAGE#*ID: }
# echo


# echo "GET query chaincode on peer1 of Org1"
# echo
# curl -s -X GET \
#   "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22t1%22%5D" \
#   -H "authorization: Bearer $ORG1_TOKEN" \
#   -H "content-type: application/json"
# echo
# echo "====================================================================================="




# echo "POST invoke chaincode on peers of Org1 and Org2 (Remov tutor from tutorial)"
# echo
# VALUES=$(curl -s -X POST \
#   http://localhost:4000/channels/mychannel/chaincodes/mycc \
#   -H "authorization: Bearer $ORG1_TOKEN" \
#   -H "content-type: application/json" \
#   -d "{
#   \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
#   \"fcn\":\"removeTutorFromTutorial\",
#   \"args\":[\"t1\",\"tu4\"]
# }")
# echo $VALUES
# # Assign previous invoke transaction id  to TRX_ID
# MESSAGE=$(echo $VALUES | jq -r ".message")
# TRX_ID=${MESSAGE#*ID: }
# echo


# echo "GET query chaincode on peer1 of Org1"
# echo
# curl -s -X GET \
#   "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22t1%22%5D" \
#   -H "authorization: Bearer $ORG1_TOKEN" \
#   -H "content-type: application/json"
# echo
# echo "====================================================================================="





# echo "POST invoke chaincode on peers of Org1 and Org2 (Remov tutor from tutorial - error)"
# echo
# VALUES=$(curl -s -X POST \
#   http://localhost:4000/channels/mychannel/chaincodes/mycc \
#   -H "authorization: Bearer $ORG1_TOKEN" \
#   -H "content-type: application/json" \
#   -d "{
#   \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
#   \"fcn\":\"removeTutorFromTutorial\",
#   \"args\":[\"t1\",\"tu10\"]
# }")
# echo $VALUES
# # Assign previous invoke transaction id  to TRX_ID
# MESSAGE=$(echo $VALUES | jq -r ".message")
# TRX_ID=${MESSAGE#*ID: }
# echo


# echo "GET query chaincode on peer1 of Org1"
# echo
# curl -s -X GET \
#   "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22t1%22%5D" \
#   -H "authorization: Bearer $ORG1_TOKEN" \
#   -H "content-type: application/json"
# echo
# echo "====================================================================================="





# echo "POST invoke chaincode on peers of Org1 and Org2 (Remov tutor from tutorial - error)"
# echo
# VALUES=$(curl -s -X POST \
#   http://localhost:4000/channels/mychannel/chaincodes/mycc \
#   -H "authorization: Bearer $ORG1_TOKEN" \
#   -H "content-type: application/json" \
#   -d "{
#   \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
#   \"fcn\":\"removeTutorFromTutorial\",
#   \"args\":[\"t1\",\"tu3\"]
# }")
# echo $VALUES
# # Assign previous invoke transaction id  to TRX_ID
# MESSAGE=$(echo $VALUES | jq -r ".message")
# TRX_ID=${MESSAGE#*ID: }
# echo


# echo "GET query chaincode on peer1 of Org1"
# echo
# curl -s -X GET \
#   "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22t1%22%5D" \
#   -H "authorization: Bearer $ORG1_TOKEN" \
#   -H "content-type: application/json"
# echo
# echo "====================================================================================="




# echo "POST invoke chaincode on peers of Org1 and Org2 (Add new conference)"
# echo
# VALUES=$(curl -s -X POST \
#   http://localhost:4000/channels/mychannel/chaincodes/mycc \
#   -H "authorization: Bearer $ORG1_TOKEN" \
#   -H "content-type: application/json" \
#   -d "{
#   \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
#   \"fcn\":\"addConference\",
#   \"args\":[\"DSC 5.0\",\"Belgrade\",\"20.11.2019.\"]
# }")
# echo $VALUES
# # Assign previous invoke transaction id  to TRX_ID
# MESSAGE=$(echo $VALUES | jq -r ".message")
# TRX_ID=${MESSAGE#*ID: }
# echo


# echo "GET query chaincode on peer1 of Org1"
# echo
# curl -s -X GET \
#   "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=query&args=%5B%22c1%22%5D" \
#   -H "authorization: Bearer $ORG1_TOKEN" \
#   -H "content-type: application/json"
# echo
# echo "====================================================================================="

