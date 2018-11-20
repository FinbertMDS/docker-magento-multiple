#!/usr/bin/env bash

source .env
MAGENTO_VERSION_ARRAY=(${MAGENTO_VERSIONES//,/ })

# install curl to wait service docker webserver start before install magento
sudo apt-get install curl

# TODO init file data/prepare_data/init.sql dynamic by magento version
function createFileInitDatabaseMysql() {
    echo 'init file data/prepare_data/init.sql done'
}

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
       cp magento/install_magento2.sh ${MAGENTO_FOLDER_SRC}
    done
}

function getVersionPhp() {
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

function buildDocker() {
    local DOCKER_BUILD_COMMAND=`getDockerCommand "build "`
    eval "${DOCKER_BUILD_COMMAND}"
}

removePersistData
initFolder
importDataMysql
copyFileInstallMagento
copyBashInstallMagento
buildDocker