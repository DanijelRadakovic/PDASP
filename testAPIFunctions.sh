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


######################## TRY TO TRANSFER MONEY WITH NOT ENOUGH ARGUMENTS ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (Transfer 500 from ur2 to ur1)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"transfer\",
  \"args\":[\"ur1\",\"ur2\"]
}")
echo "$VALUES"
echo


######################## TRY TO TRANSFER MONEY WITH ZERO AMOUNT ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (Transfer 0 from ur2 to ur1)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"transfer\",
  \"args\":[\"ur1\",\"ur2\",\"0\",\"n\"]
}")
echo "$VALUES"
echo


######################## TRY TO TRANSFER MONEY WITH NEGATIVE AMOUNT ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (Transfer -500 from ur2 to ur1)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"transfer\",
  \"args\":[\"ur1\",\"ur2\",\"-500\",\"n\"]
}")
echo "$VALUES"
echo


######################## TRY TO TRANSFER MONEY WITH INVALID AMOUNT ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (Transfer ttt from ur2 to ur1)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"transfer\",
  \"args\":[\"ur1\",\"ur2\",\"ttt\",\"n\"]
}")
echo "$VALUES"
echo


######################## TRY TO CREATE LOAN WITH INVALID DATE FORMAT ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (Create new bank)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"createLoan\",
  \"args\":[\"ur5\",\"25.02.2020\",\"25.02.2021\",\"0.02\",\"12\",\"1000\"]
}")
echo "$VALUES"
echo


######################## TRY TO CREATE NEW LOAN WITH ZERO NUMBER OF INTALLMENTS ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (Create new loan for ur1 that already has loan)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"createLoan\",
  \"args\":[\"ur1\",\"25.02.2020.\",\"25.02.2021.\",\"0.5\",\"0\",\"1000\"]
}")
echo "$VALUES"
echo


######################## TRY TO CREATE NEW LOAN WITH NEGATIVE NUBMER OF INTALLMENTS ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (Create new loan for ur1 that already has loan)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"createLoan\",
  \"args\":[\"ur1\",\"25.02.2020.\",\"25.02.2021.\",\"0.5\",\"-1\",\"1000\"]
}")
echo "$VALUES"
echo


######################## TRY TO CREATE NEW LOAN WITH INVALID NUMBER OF INTALLMENTS ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (Create new loan for ur1 that already has loan)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"createLoan\",
  \"args\":[\"ur1\",\"25.02.2020.\",\"25.02.2021.\",\"0.5\",\"t\",\"1000\"]
}")
echo "$VALUES"
echo


######################## TRY TO CREATE NEW LOAN WITH ZERO BASE ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (Create new loan for ur1 that already has loan)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"createLoan\",
  \"args\":[\"ur1\",\"25.02.2020.\",\"25.02.2021.\",\"0.5\",\"1\",\"0\"]
}")
echo "$VALUES"
echo


######################## TRY TO CREATE NEW LOAN WITH NEGATIVE BASE ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (Create new loan for ur1 that already has loan)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"createLoan\",
  \"args\":[\"ur1\",\"25.02.2020.\",\"25.02.2021.\",\"0.5\",\"1\",\"-1000\"]
}")
echo "$VALUES"
echo


######################## TRY TO CREATE NEW LOAN WITH INVALID BASE ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (Create new loan for ur1 that already has loan)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"createLoan\",
  \"args\":[\"ur1\",\"25.02.2020.\",\"25.02.2021.\",\"0.5\",\"1\",\"t\"]
}")
echo "$VALUES"
echo


######################## TRY TO CREATE NEW LOAN WITH ZERO INTEREST RATE ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (Create new loan for ur1 that already has loan)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"createLoan\",
  \"args\":[\"ur1\",\"25.02.2020.\",\"25.02.2021.\",\"0\",\"1\",\"1000\"]
}")
echo "$VALUES"
echo


######################## TRY TO CREATE NEW LOAN WITH NEGATIVE INTEREST RATE ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (Create new loan for ur1 that already has loan)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"createLoan\",
  \"args\":[\"ur1\",\"25.02.2020.\",\"25.02.2021.\",\"-0.5\",\"1\",\"1000\"]
}")
echo "$VALUES"
echo


######################## TRY TO CREATE NEW LOAN WITH INVALID INTEREST RATE ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (Create new loan for ur1 that already has loan)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"createLoan\",
  \"args\":[\"ur1\",\"25.02.2020.\",\"25.02.2021.\",\"t\",\"1\",\"1000\"]
}")
echo "$VALUES"
echo


######################## TRY TO CREATE NEW LOAN WITH REPAYMENT END DAY IS BEFORE APPROVAL DATE ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (Create new loan for ur1 that already has loan)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"createLoan\",
  \"args\":[\"ur1\",\"25.02.2021.\",\"25.02.2020.\",\"0.5\",\"1\",\"1000\"]
}")
echo "$VALUES"
echo


######################## TRY TO CREATE NEW LOAN WITH NOT ENOUGH ARGUMENTS ########################

echo "POST invoke chaincode on peers of Org1 and Org2 (Create new loan for ur1 that already has loan)"
echo
VALUES=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
  \"peers\": [\"peer0.org1.example.com\",\"peer0.org2.example.com\"],
  \"fcn\":\"createLoan\",
  \"args\":[\"ur1\",\"25.02.2021.\",\"25.02.2020.\",\"0.5\",\"1\"]
}")
echo "$VALUES"
echo