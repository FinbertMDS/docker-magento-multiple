#!/usr/bin/env bash

source .env
MAGENTO_VERSION_ARRAY=(${MAGENTO_VERSIONES//,/ })

# get version php from version magento
function get_version_php() {
    PHP_VERSION=""
    if [[ ${1} == 2.2* ]]; then
        PHP_VERSION="7.1"
    elif [[ ${1} == 2.1* ]]; then
        PHP_VERSION="7.0"
    elif [[ ${1} == 1.* ]]; then
        PHP_VERSION="5.6"
    fi
    echo ${PHP_VERSION}
}

# get port of service docker.
# if port >= 6 character, remove last character
# ex: version magento is 2.2.6 => port: 22671; 2.1.15 => port: 21157
function get_port_service_docker() {
    PORT_SERVICE_DOCKER=''
    local PHP_VERSION=`get_version_php "${1}"`
    if [[ ! -z "${PHP_VERSION}" ]]; then
        PORT_SERVICE_DOCKER="${1//./}""${PHP_VERSION//./}"
        while [[ ${#PORT_SERVICE_DOCKER} > 5 ]]; do
            PORT_SERVICE_DOCKER="${PORT_SERVICE_DOCKER::-1}"
        done
    fi
    echo ${PORT_SERVICE_DOCKER}
}

# run docker compose command with all file docker compose defined
function get_docker_command() {
    local DOCKER_BUILD_COMMAND='docker-compose -f docker-compose.yml '
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        local PHP_VERSION=`get_version_php "${i}"`
        if [[ ! -z "${PHP_VERSION}" ]]; then
            DOCKER_BUILD_COMMAND=${DOCKER_BUILD_COMMAND}'-f docker-compose-magento-'${i}'-php-'${PHP_VERSION}'.yml '
        fi
    done
    DOCKER_BUILD_COMMAND=${DOCKER_BUILD_COMMAND}${1}
    echo ${DOCKER_BUILD_COMMAND}
}

# print status
function print_status() {
    echo "## $1"
}

# print Done
function print_done() {
    echo "Done."
}

# quit process
function bail() {
    echo 'Error executing command, exiting'
    exit 1
}

# exec cmd, if error still continuous process
function exec_cmd_nobail() {
    echo "+ $1"
    bash -c "$1"
}

# exec cmd, if error quit process
function exec_cmd() {
    exec_cmd_nobail "$1" || bail
}

function curl_check () {
  echo "Checking for curl..."
  if command -v curl > /dev/null; then
    echo "Detected curl..."
  else
    echo "Installing curl..."
    sudo apt-get install -q -y curl
    if [ "$?" -ne "0" ]; then
      echo "Unable to install curl! Your base system has a problem; please check your default OS's package repositories because curl should work."
      echo "Repository installation aborted."
      exit 1
    fi
  fi
}

function main() {
    curl_check
}

main
