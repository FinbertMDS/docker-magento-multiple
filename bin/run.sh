#!/usr/bin/env bash

source bin/common.sh

function run_docker() {
    local docker_build_command=`get_docker_command "up -d"`
    exec_cmd "${docker_build_command}"
}

function run_sql_init_database() {
    init_database_file='data/init_data/database.sql'
    docker_container_name_db='docker-magento-multiple_db_1'
    exec_cmd "until docker exec -it ${docker_container_name_db} bash -c 'mysql --user=root --password=${MYSQL_ROOT_PASSWORD} --execute \"SHOW DATABASES;\"' > /dev/null 2>&1; do sleep 2; done"
    exec_cmd "docker cp ${init_database_file} ${docker_container_name_db}:/docker-entrypoint-initdb.d/database.sql"
    exec_cmd "docker exec ${docker_container_name_db} bash -c 'mysql -u root --password=${MYSQL_ROOT_PASSWORD} < docker-entrypoint-initdb.d/database.sql'"
}

function wait_service_docker_start_done() {
    local port_service_docker=`get_port_service_docker "${1}"`
    if [[ ! -z "${port_service_docker}" ]]; then
        while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' 127.0.0.1:"${port_service_docker}")" != "200" ]];
        do
            echo "waiting service start at port "${port_service_docker}" ..."
            sleep 3
        done
        echo 'start service docker at port '${port_service_docker}' done!'
    fi
}

function wait_for_all_service_start_done() {
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        wait_service_docker_start_done ${i}
    done
}

function install_magento() {
    local php_version=`get_version_php ${1}`
    if [[ ! -z ${php_version} ]]; then
        local docker_container_name="docker-magento-multiple_magento_"${1}"_"${php_version}"_1"
        docker exec ${docker_container_name} bash -c "chown -R www-data:www-data . && chmod -R 777 ."
        docker exec -u www-data ${docker_container_name} bash -c "./install_magento.sh"
    fi
}

function install_magento_for_all_containers() {
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        install_magento ${i}
    done
}

function add_host_to_local() {
    print_status "Add host to local..."
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        exec_cmd "grep -q -F '127.0.0.1 magento`get_port_service_docker "${i}"`.com' /etc/hosts || echo '127.0.0.1 magento`get_port_service_docker "${i}"`.com' | sudo tee --append /etc/hosts > /dev/null"
    done
    print_done
}

function print_site_magento_list() {
    print_status "Site magento list:"
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        local port_service_docker=`get_port_service_docker "${i}"`
        echo
        echo "Magento version ${i}"
        echo "Frontend: http://magento${port_service_docker}.com:${port_service_docker}/"
        echo "Backend: http://magento${port_service_docker}.com:${port_service_docker}/admin"
    done
}

function main() {
    run_docker
    run_sql_init_database
    install_magento_for_all_containers
    add_host_to_local
    print_site_magento_list
}

calculate_time_run_command main