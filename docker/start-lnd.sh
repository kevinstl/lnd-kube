#!/usr/bin/env bash

# exit from script if error was raised.
set -e

# error function is used within a bash function in order to send the error
# message directly to the stderr output and exit.
error() {
    echo "$1" > /dev/stderr
    exit 0
}

# return is used within bash function in order to return the value.
return() {
    echo "$1"
}

# set_default function gives the ability to move the setting of default
# env variable from docker file to the script thereby giving the ability to the
# user override it durin container start.
set_default() {
    # docker initialized env variables with blank string and we can't just
    # use -z flag as usually.
    BLANK_STRING='""'

    VARIABLE="$1"
    DEFAULT="$2"

    if [[ -z "$VARIABLE" || "$VARIABLE" == "$BLANK_STRING" ]]; then

        if [ -z "$DEFAULT" ]; then
            error "You should specify default variable"
        else
            VARIABLE="$DEFAULT"
        fi
    fi

   return "$VARIABLE"
}

# Set default variables if needed.
RPCUSER=$(set_default "$RPCUSER" "devuser_change")
RPCPASS=$(set_default "$RPCPASS" "devpass_change")
DEBUG=$(set_default "$DEBUG" "debug")
NETWORK=$(set_default "$NETWORK" "simnet")
CHAIN=$(set_default "$CHAIN" "bitcoin")
#BACKEND="btcd"
BACKEND=$(set_default "$BACKEND" "btcd")

if [[ "$CHAIN" == "litecoin" ]]; then
    BACKEND="ltcd"
fi

echo "debug1"
echo "DEPLOYMENT_NAME: ${DEPLOYMENT_NAME}"
echo "NETWORK: ${NETWORK}"

deploymentNameDir=""
if [[ ! -z "$DEPLOYMENT_NAME" ]]; then
    echo "debug2"
    deploymentNameDir="/$DEPLOYMENT_NAME"
fi

echo "debug3"
echo "deploymentNameDir: ${deploymentNameDir}"


baseDir="/mnt/${NETWORK}"
baseDir="/mnt/${NETWORK}"
baseLndDir=${baseDir}/lnd
baseRpcDir=${baseDir}/shared/rpc

rpcCertArg=""
if [[ "$BACKEND" == "btcd" ]]; then
    rpcCertArg="--$BACKEND.rpccert=${baseRpcDir}/rpc.cert "
fi

zmqpubrawblockArg=""
zmqpubrawtxArg=""
if [[ "$BACKEND" == "bitcoind" ]]; then
    zmqpubrawblockArg="--$BACKEND.zmqpubrawblock=tcp://127.0.0.1:28332 "
    zmqpubrawtxArg="--$BACKEND.zmqpubrawtx=tcp://127.0.0.1:28333 "
#    zmqpubrawblockArg="--$BACKEND.zmqpubrawblock=tcp://$BACKEND-kube.lightning-kube-$NETWORK:28332 "
#    zmqpubrawtxArg="--$BACKEND.zmqpubrawtx=tcp://$BACKEND-kube.lightning-kube-$NETWORK:28333 "
fi

mkdir -p ${baseRpcDir}

exec lnd \
    --noseedbackup \
    --datadir="${baseLndDir}${deploymentNameDir}/data" \
    --logdir="${baseLndDir}${deploymentNameDir}/log" \
    "--$CHAIN.active" \
    "--$CHAIN.$NETWORK" \
    "--$CHAIN.node"="$BACKEND" \
    "$rpcCertArg" \
    "$zmqpubrawblockArg" \
    "$zmqpubrawtxArg" \
    "--$BACKEND.rpchost"="$BACKEND-kube.lightning-kube-$NETWORK" \
    "--$BACKEND.rpcuser"="$RPCUSER" \
    "--$BACKEND.rpcpass"="$RPCPASS" \
    --debuglevel="$DEBUG" \
    "$@"


#    "--$CHAIN.node"="btcd" \
#    "--$BACKEND.rpchost"="btcd-kube.lightning-kube-$NETWORK" \

