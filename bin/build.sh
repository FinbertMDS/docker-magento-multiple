#!/usr/bin/env bash

source .env
MAGENTO_VERSION_ARRAY=(${MAGENTO_VERSIONES//,/ })

# remove all persist data
function removePersistData() {
    sudo rm -rf data/mysql/*
    sudo rm -rf src/*
    sudo rm -rf src/.*
}

# init folder persist data
function initFolder() {
    mkdir -p data/mysql
    mkdir -p src
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        local MAGENTO_FOLDER_SRC='src/'${i}
        mkdir -p ${MAGENTO_FOLDER_SRC}
    done
}

# check add file tar.gz of all version magento existed
function checkAllFileInstallMagentoExist() {
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
       local MAGENTO_FILENAME_SRC='magento2-'${i}'.tar.gz'
       if [[ ! -f 'magento/'${MAGENTO_FILENAME_SRC} ]]; then
          echo "Please place file ${MAGENTO_FILENAME_SRC} at folder magento"
          exit
       fi
       local MAGENTO_FOLDER_SRC='magento/src/'${i}
       if [[ ! -f ${MAGENTO_FOLDER_SRC}${MAGENTO_FILENAME_SRC} ]]; then
            cp 'magento/'${MAGENTO_FILENAME_SRC} ${MAGENTO_FOLDER_SRC}
        fi
    done
}

function copyBashInstallMagento() {
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
       local MAGENTO_FOLDER_SRC='magento/src/'${i}
       cp magento/install_magento.sh ${MAGENTO_FOLDER_SRC}
    done
}

function buildDocker() {
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
    DOCKER_BUILD_COMMAND=${DOCKER_BUILD_COMMAND}'build '
    eval "${DOCKER_BUILD_COMMAND}"
}

removePersistData
initFolder
checkAllFileInstallMagentoExist
copyBashInstallMagento
buildDocker