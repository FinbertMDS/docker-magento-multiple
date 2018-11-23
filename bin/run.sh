#!/usr/bin/env bash

source bin/common.sh

function runDocker() {
    local DOCKER_BUILD_COMMAND=`get_docker_command "up -d"`
    exec_cmd "${DOCKER_BUILD_COMMAND}"
}

function waitServiceDockerStartDone() {
    local PORT_SERVICE_DOCKER=`get_port_service_docker "${1}"`
    if [[ ! -z "${PORT_SERVICE_DOCKER}" ]]; then
        while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' 127.0.0.1:"${PORT_SERVICE_DOCKER}")" != "200" ]];
        do
            echo "waiting service start at port "${PORT_SERVICE_DOCKER}" ..."
            sleep 3
        done
        echo 'start service docker at port '${PORT_SERVICE_DOCKER}' done!'
    fi
}

function waitForAllServiceStartDone() {
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        waitServiceDockerStartDone ${i}
    done
}

function installMagento2() {
    local PHP_VERSION=`get_version_php ${1}`
    if [[ ! -z ${PHP_VERSION} ]]; then
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

function add_host_to_local() {
    print_status "Add host to local..."
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        exec_cmd "grep -q -F '127.0.0.1 magento`get_port_service_docker "${i}"`.com' /etc/hosts || echo '127.0.0.1 magento`get_port_service_docker "${i}"`.com' | sudo tee --append /etc/hosts > /dev/null"
    done
    print_status "Done."
}

function print_site_magento_list() {
    print_status "Site magento list:"
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        local PORT_SERVICE_DOCKER=`get_port_service_docker "${i}"`
        echo
        echo "Magento version ${i}"
        echo "Frontend: http://magento${PORT_SERVICE_DOCKER}.com:${PORT_SERVICE_DOCKER}/"
        echo "Backend: http://magento${PORT_SERVICE_DOCKER}.com:${PORT_SERVICE_DOCKER}/admin"
    done
}

function main() {
    runDocker
    installMagentoForAllContainers
    add_host_to_local
    print_site_magento_list
    # TODO install for magento 1
}

calculate_time_run_command main