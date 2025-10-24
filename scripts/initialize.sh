#!/usr/bin/env bash
set -e

echo "Starting container for $GIT_COMMITTER_NAME ($GIT_COMMITTER_EMAIL) in $GITHUB_REPOSITORY"

CONNECT_ENV_FILE=${CONNECT_ENV_FILE:-"op-connect.env"}

# If the token is empty and the env file is missing and it's not codespaces, create a new token
if [ -z "${OP_CONNECT_TOKEN}" ] && [ ! -f $CONNECT_ENV_FILE ] && [ "${CODESPACES}" != "true" ]; then
    if [ -n "${OP_CONNECT_HOST}" ] && [ -n "${OP_VAULT_NAME}" ] && [ -n "${OP_CONNECT_SERVER}" ]; then
        # the host can't be set when creating a token with the cli
        TMP_OP_CONNECT_HOST="$OP_CONNECT_HOST"
        unset OP_CONNECT_HOST 
        # get the token
        OP_CONNECT_TOKEN="$(op connect token create "${OP_CONNECT_TOKEN_NAME:-devcontainer}" --server $OP_CONNECT_SERVER --vault $OP_VAULT_NAME --expires-in 48h)"
        cat <<EOF > $CONNECT_ENV_FILE
OP_CONNECT_HOST=$TMP_OP_CONNECT_HOST
OP_CONNECT_TOKEN=$OP_CONNECT_TOKEN
EOF
    else
        echo "ERROR: OP_CONNECT_HOST, OP_VAULT_NAME, and OP_CONNECT_SERVER must all be set to create a token."
        exit 1
    fi
else
    if [ -f $CONNECT_ENV_FILE ]; then
        echo "Using existing $CONNECT_ENV_FILE file."
    else
        # make it anyway to so codespaces doesn't complain
        touch $CONNECT_ENV_FILE
    fi
    # if the connect host and token are non empty then make a message that these will be used
    if [ -n "${OP_CONNECT_HOST}" ] && [ -n "${OP_CONNECT_TOKEN}" ]; then
        echo "Using existing OP_CONNECT_HOST and OP_CONNECT_TOKEN environment variables."
    fi
fi

