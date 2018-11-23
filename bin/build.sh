#!/usr/bin/env bash

source bin/common.sh

# init file data/prepare_data/init.sql dynamic by magento version
function create_file_init_database_mysql() {
    print_status 'Init file data/prepare_data/init.sql...'
    INIT_DATABASE_FILE='data/prepare_data/init.sql'
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
    sudo rm -rf data/mysql
    sudo rm -rf src
}

# init folder persist data
function init_folder() {
    mkdir -p data/mysql
    mkdir -p src
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        local MAGENTO_FOLDER_SRC='src/'${i}
        mkdir -p ${MAGENTO_FOLDER_SRC}
    done
}

# prepare file mysql to import to database
function import_data_mysql() {
    MYSQL_INIT_DATA_FOLDER='data/init_data/'
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
function copy_file_install_magento() {
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

function copy_bash_install_magento() {
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
       local MAGENTO_FOLDER_SRC='src/'${i}
       cp magento/install_magento2.sh ${MAGENTO_FOLDER_SRC}
       cp magento/mysql.php ${MAGENTO_FOLDER_SRC}
    done
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
    copy_bash_install_magento
    build_docker
}

calculate_time_run_command main