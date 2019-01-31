#!/usr/bin/env bash

source bin/common.sh

CONTAINER_NAME_LIST=()
USER_LIST=('root', 'www-data')
USER='www-data'

function validate_ssh() {
    if [[ -z ${1} ]]; then
        exit_print_error 'Missing version magento.'
    fi
    if [[ ! ${MAGENTO_VERSIONES} == *"${1}"* ]] && [[ ! $1 = 'db' ]]; then
        exit_print_error 'Param 1 had to be "version magento" or "db".'
    fi
}

function validate_user_remote() {
    if [[ ! -z $1 ]]; then
        USER=$1
    fi
    local match=$(echo "${USER_LIST[@]:0}" | grep -o ${USER})
    if [[ -z ${match} ]]; then
        exit_print_error 'Param 2 had to be "root" or "www-data"(with docker magento).'
    fi
}

function remote_container() {
    if [[ ${MAGENTO_VERSIONES} == *"${1}"* ]]; then
        local php_version=`get_version_php ${1}`
        local docker_container_name="docker-magento-multiple_magento_"${1}"_"${php_version}"_1"
        echo 'Docker container name: '${docker_container_name}
        docker exec -it -u ${USER} ${docker_container_name} bash
    fi
    if [[ $1 = 'db' ]]; then
        echo 'Docker container name: docker-magento-multiple_db_1'
        docker exec -it -u root docker-magento-multiple_db_1 bash
    fi
}

function main() {
    echo 'Param 1 is one of the some value to remote: '${MAGENTO_VERSIONES}',db'
#    read ssh_name
    local ssh_name=${1}
    if [[ -z ${1} ]]; then
        ssh_name=${MAGENTO_VERSIONES[0]}
    fi
    local user_name=''
    if [[ ! ${ssh_name} = 'db' ]]; then
        echo 'Param 2 is one of value: root,www-data'
#        read user_name
        user_name=${2}
    else
        user_name='root'
    fi
    validate_ssh ${ssh_name}
    validate_user_remote ${user_name}
    remote_container ${ssh_name}
}

main $1 $2