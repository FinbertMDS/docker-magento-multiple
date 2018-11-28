#!/usr/bin/env bash

source bin/common.sh

# init file data/prepare_data/database.sql dynamic by magento version
function create_file_init_database_mysql() {
    print_status 'Init file data/prepare_data/database.sql...'
    INIT_DATABASE_FILE='data/prepare_data/database.sql'
    rm -f ${INIT_DATABASE_FILE}
    touch ${INIT_DATABASE_FILE}
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        local PORT_SERVICE_DOCKER=`get_port_service_docker "${i}"`
        local INIT_DATABASE_STRING='CREATE DATABASE IF NOT EXISTS magento'${PORT_SERVICE_DOCKER}';'
        echo ${INIT_DATABASE_STRING} >> ${INIT_DATABASE_FILE}
    done
    print_done
}

# remove all persist data
function remove_persist_data() {
    print_status "Remove persist data..."
    rm -rf data/init_data
#    sudo rm -rf data/mysql
    sudo rm -rf src/*
    print_done
}

# init folder persist data
function init_folder() {
    print_status "Init folder to persist data docker..."
    mkdir -p data/mysql
    mkdir -p src
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        local MAGENTO_FOLDER_SRC='src/'"${i//./}"
        mkdir -p ${MAGENTO_FOLDER_SRC}
    done
    print_done
}

# prepare file mysql to import to database
function import_data_mysql() {
    print_status "Init sql to import to databases..."
    MYSQL_INIT_DATA_FOLDER='data/init_data/'
    mkdir -p ${MYSQL_INIT_DATA_FOLDER}

    cp 'data/prepare_data/database.sql' ${MYSQL_INIT_DATA_FOLDER}'database.sql'

    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        local MYSQL_FILENAME='data/prepare_data/'${i}'.sql'
        if [[ -f ${MYSQL_FILENAME} ]]; then
            cp ${MYSQL_FILENAME} ${MYSQL_INIT_DATA_FOLDER}${i}'.sql'
        fi
    done
    print_done
}

# check add file tar.gz of all version magento existed
function copy_file_install_magento() {
    print_status "Copy source code magento and file install magento to volume docker..."
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        MAGENTO_VERSION=`get_version_magento ${i}`
        MAGENTO_FILENAME_SRC='magento'${MAGENTO_VERSION}'-'${i}'.tar.gz'
        if [[ ! -f 'magento/'${MAGENTO_FILENAME_SRC} ]]; then
          echo "Please place file ${MAGENTO_FILENAME_SRC} at folder magento"
          exit
        fi
        local MAGENTO_FOLDER_SRC='src/'"${i//./}"
        if [[ ! -f ${MAGENTO_FOLDER_SRC}${MAGENTO_FILENAME_SRC} ]]; then
            cp 'magento/'${MAGENTO_FILENAME_SRC} ${MAGENTO_FOLDER_SRC}'/magento.tar.gz'
        fi
        if [[ ${SAMPLE_DATA} = '1' ]]; then
            if [[ ${MAGENTO_VERSION} = '1' ]]; then
                MAGENTO_SAMPLE_DATA_VERSION=`get_version_sample_data_magento1 ${i}`
                local MAGENTO_SAMPLE_FILENAME='magento/magento1-sample-data-'${MAGENTO_SAMPLE_DATA_VERSION}'.tar.gz'
                cp ${MAGENTO_SAMPLE_FILENAME} ${MAGENTO_FOLDER_SRC}'/magento-sample.tar.gz'
                tar xvf ${MAGENTO_FOLDER_SRC}'/magento-sample.tar.gz' -C ${MAGENTO_FOLDER_SRC} &> /dev/null
                rsync -av ${MAGENTO_FOLDER_SRC}'/magento-sample-data-'${MAGENTO_SAMPLE_DATA_VERSION}'/' ${MAGENTO_FOLDER_SRC}'/' &> /dev/null
                rm -rf ${MAGENTO_FOLDER_SRC}'/magento-sample-data-'${MAGENTO_SAMPLE_DATA_VERSION}'/'
            fi
        fi
        cp 'magento/install_magento'${MAGENTO_VERSION}'.sh' ${MAGENTO_FOLDER_SRC}'/install_magento.sh'
        cp magento/mysql.php ${MAGENTO_FOLDER_SRC}
    done
    print_done
}

function build_docker() {
    print_status "Building docker..."
    local DOCKER_BUILD_COMMAND=`get_docker_command "build "`
    exec_cmd "${DOCKER_BUILD_COMMAND}"
    print_done
}

function main() {
    remove_persist_data
    init_folder
    create_file_init_database_mysql
    import_data_mysql
    copy_file_install_magento
    build_docker
}

calculate_time_run_command main