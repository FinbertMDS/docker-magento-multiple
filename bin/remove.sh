#!/usr/bin/env bash

source .env
MAGENTO_VERSION_ARRAY=(${MAGENTO_VERSIONES//,/ })

function removeDocker() {
    local DOCKER_BUILD_COMMAND='docker-compose -f docker-compose.yml '
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
         if [[ ${i} == 2.2* ]]; then
            DOCKER_BUILD_COMMAND=${DOCKER_BUILD_COMMAND}'-f docker-compose-magento-'${i}'-php-7.1.yml '
         fi
         if [[ ${i} == 2.1* ]]; then
            DOCKER_BUILD_COMMAND=${DOCKER_BUILD_COMMAND}'-f docker-compose-magento-'${i}'-php-7.0.yml '
         fi
    done
    DOCKER_BUILD_COMMAND=${DOCKER_BUILD_COMMAND}'down '
    eval "${DOCKER_BUILD_COMMAND}"
}

removeDocker