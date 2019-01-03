#!/usr/bin/env bash

source bin/common.sh

function create_backup_data_in_docker() {
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        local port_service_docker=`get_port_service_docker "${i}"`
        local sql_backup_database='mysqldump -u root -pmagento magento'${port_service_docker}' > magento'${port_service_docker}'.sql'
        if [[ ! -f 'data/prepare_data/'${i}'.sql' ]]; then
            echo 'Need backup database for version: '${i}
            exec_cmd "docker exec docker-magento-multiple_db_1 bash -c '${sql_backup_database}'"
        fi
    done
}

function copy_file_from_docker_to_host() {
    local backup_db_folder='data/prepare_data/'
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        local port_service_docker=`get_port_service_docker "${i}"`
        local sql_backup_filename=${backup_db_folder}${i}'.sql'
        if [[ ! -f ${sql_backup_filename} ]]; then
            exec_cmd "docker cp docker-magento-multiple_db_1:magento${port_service_docker}.sql ${sql_backup_filename}"
        fi
    done
}

function main() {
    create_backup_data_in_docker
    copy_file_from_docker_to_host
}

main