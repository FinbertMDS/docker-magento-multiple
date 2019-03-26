#!/usr/bin/env bash

source bin/common.sh

CONTAINER_NAME_LIST=()
USER_LIST=('root', 'www-data')
USER='www-data'

function validate_ssh() {
    if [[ -z ${1} ]]; then
        exit_print_error 'Error: Missing version magento.'
    fi
    if [[ ! ${MAGENTO_VERSIONES} == *"${1}"* ]]; then
        exit_print_error 'Error: Param 1 had to be "version magento"'
    fi
}

function validate_user_remote() {
    if [[ ! -z $1 ]]; then
        USER=$1
    fi
    local match=$(echo "${USER_LIST[@]:0}" | grep -o ${USER})
    if [[ -z ${match} ]]; then
        exit_print_error 'Error: Param 2 had to be "root" or "www-data".'
    fi
}

function remote_container() {
    if [[ ${MAGENTO_VERSIONES} == *"${1}"* ]]; then
#        local php_version=`get_version_php ${1}`
#        local docker_container_name="docker-magento-multiple_magento_"${1}"_"${php_version}"_1"
        local port_service_docker=`get_port_service_docker "${1}"`
		local docker_container_name="magento${port_service_docker}"
        echo 'Docker container name: '${docker_container_name}
        local docker_command=`get_docker_command`
        ${docker_command} exec -u ${USER} ${docker_container_name} bash
    fi
}

function main() {
	echo "Suggest:"
	echo "Param 1 had to be version magento"
	echo "Param 2 had to be root or www-data."
    local ssh_name=${1}
    if [[ -z ${1} ]]; then
        ssh_name=${MAGENTO_VERSIONES[0]}
    fi
    validate_ssh ${ssh_name}
    local user_name=${2}
    validate_user_remote ${user_name}
    remote_container ${ssh_name}
}

main $1 $2