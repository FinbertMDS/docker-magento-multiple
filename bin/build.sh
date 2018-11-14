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

# prepare file mysql to import to database
function importDataMysql() {
    local MYSQL_INIT_DATA_FOLDER='data/init_data/'
    mkdir -p ${MYSQL_INIT_DATA_FOLDER}

    cp 'data/prepare_data/init.sql' ${MYSQL_INIT_DATA_FOLDER}'init.sql'

    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        local MYSQL_FILENAME='data/prepare_data/'${i}'.sql'
        if [[ -f ${MYSQL_FILENAME} ]]; then
            cp ${MYSQL_FILENAME} ${MYSQL_INIT_DATA_FOLDER}${i}'.sql'
        fi
    done
}

# check add file tar.gz of all version magento existed
function copyFileInstallMagento() {
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
       local MAGENTO_FILENAME_SRC='magento2-'${i}'.tar.gz'
       if [[ ! -f 'magento/'${MAGENTO_FILENAME_SRC} ]]; then
          echo "Please place file ${MAGENTO_FILENAME_SRC} at folder magento"
          exit
       fi
       local MAGENTO_FOLDER_SRC='src/'${i}
       if [[ ! -f ${MAGENTO_FOLDER_SRC}${MAGENTO_FILENAME_SRC} ]]; then
            cp 'magento/'${MAGENTO_FILENAME_SRC} ${MAGENTO_FOLDER_SRC}'/magento.tar.gz'
        fi
    done
}

function copyBashInstallMagento() {
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
       local MAGENTO_FOLDER_SRC='src/'${i}
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
importDataMysql
copyFileInstallMagento
copyBashInstallMagento
buildDocker