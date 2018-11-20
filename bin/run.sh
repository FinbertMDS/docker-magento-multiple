#!/usr/bin/env bash

source .env
MAGENTO_VERSION_ARRAY=(${MAGENTO_VERSIONES//,/ })

function getVersionPhp() {
    PHP_VERSION=""
    if [[ ${1} == 2.2* ]]; then
        PHP_VERSION="7.1"
    elif [[ ${1} == 2.1* ]]; then
        PHP_VERSION="7.0"
    elif [[ ${1} == 1.* ]]; then
        PHP_VERSION="5.6"
    fi
    return ${PHP_VERSION}
}

function getDockerCommand() {
    local DOCKER_BUILD_COMMAND='docker-compose -f docker-compose.yml '
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        local PHP_VERSION=`getVersionPhp "${i}"`
        if [[ -z "${PHP_VERSION}" ]]; then
            DOCKER_BUILD_COMMAND=${DOCKER_BUILD_COMMAND}'-f docker-compose-magento-'${i}'-php-'${PHP_VERSION}'.yml '
        fi
    done
    DOCKER_BUILD_COMMAND=${DOCKER_BUILD_COMMAND}${1}
    return ${DOCKER_BUILD_COMMAND}
}

function runDocker() {
    local DOCKER_BUILD_COMMAND=`getDockerCommand "up "`
    eval "${DOCKER_BUILD_COMMAND}"
}

# TODO get port of service docker.
# if port >= 6 character, remove last character
# ex: version magento is 2.2.6 => port: 22671; 2.1.15 => port: 21157
function getPortServiceDocker() {
    PORT_SERVICE_DOCKER=''
    return ${PORT_SERVICE_DOCKER}
}

# TODO wait service docker start done, ready to install magento
function waitServiceDockerStartDone() {
    echo 'start service docker done'
}

function installMagento2() {
    local PHP_VERSION=`getVersionPhp ${1}`
    if [[ -z ${PHP_VERSION} ]]; then
        local DOCKER_NAME="docker-magento-multiple_magento_"${1}"_"${PHP_VERSION}"_1"
        docker exec ${DOCKER_NAME} bash -c "chown -R www-data:www-data . && chmod -R 777 ."
        docker exec -u www-data ${DOCKER_NAME} bash -c "./install_magento2.sh"
    fi
}

function installMagentoForAllContainers() {
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        installMagento2 ${i}
    done
}

runDocker
waitServiceDockerStartDone
installMagentoForAllContainers

# TODO install for magento 1