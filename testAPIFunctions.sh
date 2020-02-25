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




######################## TRY TO CREATE NEW BANK WITH INVALID YEAR ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (Create new bank)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"createBank\",
  \"args\":[\"TestBank\",\"ttt\",\"5000\",\"UK\",\"USA\",\"Poland\",\"Slovakia\",\"Denmark\"]
}")
echo "$VALUES"
echo


######################## TRY TO CREATE NEW BANK WITH INVALID BALANCE ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (Create new bank)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"createBank\",
  \"args\":[\"TestBank\",\"2003\",\"30K\",\"UK\",\"USA\",\"Poland\",\"Slovakia\",\"Denmark\"]
}")
echo "$VALUES"
echo


######################## TRY TO CREATE NEW BANK WITH INVALID NEGATIVE BALANCE ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (Create new bank)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"createBank\",
  \"args\":[\"TestBank\",\"2003\",\"-1000\",\"UK\",\"USA\",\"Poland\",\"Slovakia\",\"Denmark\"]
}")
echo "$VALUES"
echo

######################## TRY TO CREATE NEW BANK WITH NOT ENOUGH ARGUMENTS ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (Create new bank)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"createBank\",
  \"args\":[\"TestBank\",\"2003\"]
}")
echo "$VALUES"
echo