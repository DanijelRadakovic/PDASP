#!/bin/bash

BASE_PATH=${PWD}
CHANNEL_PATH=${BASE_PATH}/artifacts/channel
CRYPTO_CONF=${CHANNEL_PATH}/cryptogen.yaml
CRYPTO_CONFIG=${CHANNEL_PATH}/crypto-config

FABRIC_PATH=${BASE_PATH}/artifacts
DOCKER_COMPOSE_TEMPLATE=${FABRIC_PATH}/docker-compose-template.yaml
DOCKER_COMPOSE=${FABRIC_PATH}/docker-compose.yaml
NETWORK_TEMPLATE=${FABRIC_PATH}/network-config-template.yaml
NETWORK=${FABRIC_PATH}/network-config.yaml

BINARIES=${BASE_PATH}/bin
export PATH=${BINARIES}:$PATH
export FABRIC_CFG_PATH=${CHANNEL_PATH}

NUMBER_ORGS=2
CA_PRIVATE_KEY_PREFIX=CA_PRIVATE_KEY_ORG
ADMIN_PRIVATE_KEY_PREFIX=ADMIN_PRIVATE_KEY_ORG

CHANNEL_NAME="mychannel"

function dkcl(){
    CONTAINER_IDS=$(docker ps -aq)
	echo
        if [[ -z "$CONTAINER_IDS" || "$CONTAINER_IDS" = " " ]]; then
                echo "========== No containers available for deletion =========="
        else
                docker rm -f "$CONTAINER_IDS"
        fi
	echo
}

function dkrm(){
    DOCKER_IMAGE_IDS=$(docker images | grep "dev\|none\|test-vp\|peer[0-9]-" | awk '{print $3}')
	echo
        if [[ -z "$DOCKER_IMAGE_IDS" || "$DOCKER_IMAGE_IDS" = " " ]]; then
		echo "========== No images available for deletion ==========="
        else
                docker rmi -f "$DOCKER_IMAGE_IDS"
        fi
	echo
}

function restartNetwork() {
	echo

  #teardown the network and clean the containers and intermediate images
	docker-compose -f "${BASE_PATH}"/artifacts/docker-compose.yaml down --volumes
	dkcl
	dkrm
	docker volume prune -f

	#Cleanup the stores
	rm -rf ./fabric-client-kv-org*

    generateCerts
    replacePrivateKeyInDockerCompose
    replacePrivateKeyInNetwork
    generateChannelArtifacts

	#Start the network
	docker-compose -f "${BASE_PATH}"/artifacts/docker-compose.yaml up -d
	echo
}

function installNodeModules() {
	echo
	if [[ -d node_modules ]]; then
        echo "============== node modules installed already ============="
	else
		echo "============== Installing node modules ============="
		npm install
	fi
	echo
}


function generateCerts() {

  if ! which cryptogen; then
    echo "cryptogen tool not found. exiting"
    exit 1
  fi
  echo
  echo "##########################################################"
  echo "##### Generate certificates using cryptogen tool #########"
  echo "##########################################################"

  if [[ -d "${CRYPTO_CONFIG}" ]]; then
    rm -Rf "${CRYPTO_CONFIG}"
  fi

  cd "${CHANNEL_PATH}" || exit
  set -x
  cryptogen generate --config="${CRYPTO_CONF}"
  res=$?
  set +x
  if [[ ${res} -ne 0 ]]; then
    echo "Failed to generate certificates..."
    exit 1
  fi
#  find ${CRYPTO_CONFIG} -type f -print0 |xargs -0 chmod 765
  cd "${BASE_PATH}" || exit
  echo
}


function replacePrivateKeyInDockerCompose() {
  # sed on MacOSX does not support -i flag with a null extension. We will use
  # 't' for our back-up's extension and delete it at the end of the function
  ARCH=$(uname -s | grep Darwin)
  if [[ "$ARCH" == "Darwin" ]]; then
    OPTS="-it"
  else
    OPTS="-i"
  fi

  # Copy the template to the file that will be modified to add the private key
  cp ${DOCKER_COMPOSE_TEMPLATE} ${DOCKER_COMPOSE}

  # The next steps will replace the template's contents with the
  # actual values of the private key file names for the two CAs.
  CURRENT_DIR=$PWD
  for (( i = 1; i <= NUMBER_ORGS; i++ )); do
    cd "${CRYPTO_CONFIG}/peerOrganizations/org${i}.example.com/ca/" || exit
    PRIVATE_KEY=$(ls *_sk)
    echo "PRIVATE KEY OF ORG${i}: ${PRIVATE_KEY}"
    echo $(ls -al ${PRIVATE_KEY})
    cd ${CURRENT_DIR} || exit
    sed ${OPTS} "s/${CA_PRIVATE_KEY_PREFIX}${i}/${PRIVATE_KEY}/g" "${DOCKER_COMPOSE}"
  done
  cd ${CURRENT_DIR} || exit

  if [[ "$ARCH" == "Darwin" ]]; then
    rm "${DOCKER_COMPOSE}t"
  fi
}

function replacePrivateKeyInNetwork() {
  # sed on MacOSX does not support -i flag with a null extension. We will use
  # 't' for our back-up's extension and delete it at the end of the function
  ARCH=$(uname -s | grep Darwin)
  if [[ "$ARCH" == "Darwin" ]]; then
    OPTS="-it"
  else
    OPTS="-i"
  fi

  # Copy the template to the file that will be modified to add the private key
  cp ${NETWORK_TEMPLATE} ${NETWORK}

  # The next steps will replace the template's contents with the
  # actual values of the private key file names for the two CAs.
  CURRENT_DIR=$PWD
  for (( i = 1; i <= NUMBER_ORGS; i++ )); do
    cd "${CRYPTO_CONFIG}/peerOrganizations/org${i}.example.com/users/Admin@org${i}.example.com/msp/keystore" || exit
    PRIVATE_KEY=$(ls *_sk)
    echo "PRIVATE KEY OF ORG${i}: ${PRIVATE_KEY}"
    echo $(ls -al ${PRIVATE_KEY})
    cd ${CURRENT_DIR} || exit
    sed ${OPTS} "s/${ADMIN_PRIVATE_KEY_PREFIX}${i}/${PRIVATE_KEY}/g" "${NETWORK}"
  done
  cd ${CURRENT_DIR} || exit

  if [[ "$ARCH" == "Darwin" ]]; then
    rm "${NETWORK}t"
  fi
}

function generateChannelArtifacts() {

  if ! which configtxgen; then
    echo "configtxgen tool not found. exiting"
    exit 1
  fi

  echo "##########################################################"
  echo "#########  Generating Orderer Genesis block ##############"
  echo "##########################################################"
  # Note: For some unknown reason (at least for now) the block file can't be
  # named orderer.genesis.block or the orderer will fail to launch!
  set -x
  configtxgen -profile TwoOrgsOrdererGenesis -outputBlock "${CHANNEL_PATH}/genesis.block" -channelID ${CHANNEL_NAME}
  res=$?
  set +x
  if [[ ${res} -ne 0 ]]; then
    echo "Failed to generate orderer genesis block..."
    exit 1
  fi
  echo
  echo "#################################################################"
  echo "### Generating channel configuration transaction '${CHANNEL_NAME}.tx' ###"
  echo "#################################################################"
  set -x
  configtxgen -profile TwoOrgsChannel \
        -outputCreateChannelTx "${CHANNEL_PATH}/${CHANNEL_NAME}.tx" \
        -channelID ${CHANNEL_NAME}
  res=$?
  set +x
  if [[ ${res} -ne 0 ]]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi

  for (( i = 1; i <= ${NUMBER_ORGS}; ++i )); do
    echo
    echo "#################################################################"
    echo "#######    Generating anchor peer update for Org${i}MSP   ##########"
    echo "#################################################################"
    set -x
    configtxgen -profile TwoOrgsChannel \
        -outputAnchorPeersUpdate "${CHANNEL_PATH}/Org${i}MSPanchors.tx"  \
        -channelID ${CHANNEL_NAME} \
        -asOrg "Org${i}MSP"
    res=$?
    set +x
    if [[ ${res} -ne 0 ]]; then
        echo "Failed to generate anchor peer update for Org${i}MSP..."
        exit 1
    fi
  done
}

restartNetwork

installNodeModules

PORT=4000 node app
