#!/usr/bin/env bash

source .env
MAGENTO_VERSION_ARRAY=(${MAGENTO_VERSIONES//,/ })

# get version php from version magento
function get_version_php() {
    local php_version=""
    if [[ ${1} == 2.3* ]]; then
        php_version="7.2"
        if [[ ${INSTALL_PWA_STUDIO} = '1' ]]; then
            php_version="7.1"
        fi
    elif [[ ${1} == 2.2* ]]; then
        php_version="7.1"
    elif [[ ${1} == 2.1* ]]; then
        php_version="7.0"
    elif [[ ${1} == 1.* ]]; then
        php_version="5.6"
    fi
    echo ${php_version}
}

function get_version_magento() {
    local magento_version=''
    if [[ ${1} == 2.* ]]; then
        magento_version=2
    elif [[ ${1} == 1.* ]]; then
        magento_version=1
    fi
    echo ${magento_version}
}

function version_lib() {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

# compare version: $1 and $2 with operator $3
# echo 1 if version $1 operator $3 with version $2 else echo 0.
# example: version_compare '1.9.4' '1.9.3' '>' => echo 1
function version_compare() {
    version_lib $1 $2
    case $? in
        0) op='=';;
        1) op='>';;
        2) op='<';;
    esac
    if [[ ${op} != $3 ]]
    then
        echo 0
    else
        echo 1
    fi
}

function get_version_sample_data_magento1() {
    if [[ ${1} == 1.* ]]; then
        local version_compare_result=`version_compare $1 '1.9.2.4' '<'`
        local magento_sample_data_version='1.9.2.4'
        if [[ ${version_compare_result} = '1' ]]; then
            magento_sample_data_version='1.9.1.0'
        fi
        echo ${magento_sample_data_version}
    fi
}

# get port of service docker.
# if port >= 6 character, remove last character
# ex: version magento is 2.2.6 => port: 22671; 2.1.15 => port: 21157
function get_port_service_docker() {
    local port_service_docker=''
    local php_version=`get_version_php "${1}"`
    if [[ ! -z "${php_version}" ]]; then
        local port_service_docker="${1//./}""${php_version//./}"
        while [[ ${#port_service_docker} > 5 ]]; do
            port_service_docker="${port_service_docker::-1}"
        done
    fi
    echo ${port_service_docker}
}

# run docker compose command with all file docker compose defined
function get_docker_command() {
    local docker_build_command='docker-compose -f docker-compose.yml '
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        local php_version=`get_version_php "${i}"`
        if [[ ! -z "${php_version}" ]]; then
            docker_build_command=${docker_build_command}'-f docker-compose-magento-'${i}'-php-'${php_version}'.yml '
        fi
    done
    local docker_build_command=${docker_build_command}${1}
    echo ${docker_build_command}
}

# print status
function print_status() {
    echo "## $1"
}

# print Done
function print_done() {
    echo "Done."
}

# quit process
function bail() {
    echo 'Error executing command, exiting'
    exit 1
}

# exec cmd, if error still continuous process
function exec_cmd_nobail() {
    echo "+ $1"
    bash -c "$1"
}

# exec cmd, if error quit process
function exec_cmd() {
    exec_cmd_nobail "$1" || bail
}

function curl_check () {
  print_status "Checking for curl..."
  if command -v curl > /dev/null; then
    print_status "Detected curl..."
  else
    print_status "Installing curl..."
    sudo apt-get install -q -y curl
    if [ "$?" -ne "0" ]; then
      echo "Unable to install curl! Your base system has a problem; please check your default OS's package repositories because curl should work."
      echo "Repository installation aborted."
      exit 1
    fi
  fi
}

function calculate_time_run_command() {
    local start=$(date +%s)
    $1
    local end=$(date +%s)
    local diff=$(( $end - $start ))
    print_status "+ ${1}: It took $diff seconds"
}

function exit_print_error() {
    echo $1
    exit
}

function print_site_magento_list() {
    print_status "Site magento list:"
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        local magento_version="${i//./}"
        echo
        echo "Magento version ${i}"
        echo "Frontend: http://m${magento_version}.io/"
        echo "Backend: http://m${magento_version}.io/admin"
    done
}

# check environment for install pwa studio: SAMPLE_DATA=0, INSTALL_PWA_STUDIO=1 and $1 is version magento which must greater or equals 2.3.0
function check_install_pwa_studio() {
    local is_install_pwa_studio=0
    if [[ ${INSTALL_PWA_STUDIO} = '1' ]]; then
        if [[ ${SAMPLE_DATA} = '0' ]]; then
            local version_compare_result=`version_compare $1 '2.3.0' '<'`
            if [[ ${version_compare_result} = '0' ]]; then
                is_install_pwa_studio=1
            fi
        fi
    fi
    echo ${is_install_pwa_studio}
}
#validate environment with install pwa studio