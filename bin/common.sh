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

function get_magento_host_name_from_version() {
	local ip_address=`hostname -I | cut -d' ' -f1`
    local port_service_docker=`get_port_service_docker "${1}"`
    local magento_url="${ip_address}:${port_service_docker}"
    local magento_version="${1//./}"
	if [[ ${INSTALL_MAGENTO_WITH_DOMAIN} = '1' ]]; then
		magento_url="${MAGENTO_URL_PREFIX}${magento_version}.${MAGENTO_URL_TLD}"
	fi
	echo ${magento_url}
}

# get magento url from version magento
function get_magento_url_from_version() {
	local magento_host_name=`get_magento_host_name_from_version ${1}`
    local magento_url="http://${magento_host_name}/"
	echo ${magento_url}
}

function get_magento_db_name() {
    local port_service_docker=`get_port_service_docker "${1}"`
    local magento_db_name="magento${port_service_docker}"
    echo ${magento_db_name}
}

function get_port_public_mapping_service_docker() {
	local docker_command=`get_docker_command`
    local port=`bash -c "${docker_command} port ${1} ${2}"`
	if [[ ! -z ${port} ]]; then
	    set -f                      # avoid globbing (expansion of *).
		local array=(${port//:/ })
		echo ${array[1]}
	fi
}

function print_site_magento_list() {
	local ip_address=`hostname -I | cut -d' ' -f1`
	local port_phpmyadmin=`get_port_public_mapping_service_docker 'phpmyadmin' 80`
	local port_mailhog=`get_port_public_mapping_service_docker 'mailhog' 8025`
	local folder_mangento=`bash -c "pwd"`
	print_status "Phpmyadmin: http://${ip_address}:${port_phpmyadmin}/"
	print_status "Mailhog: http://${ip_address}:${port_mailhog}/"
    print_status "Site magento list:"
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        local magento_url=`get_magento_url_from_version ${i}`
        local port_service_docker=`get_port_service_docker ${i}`
        echo
        echo "Magento version ${i}"
        echo "Frontend: ${magento_url}"
        echo "Backend: ${magento_url}admin"
        echo "Folder magento: ${folder_mangento}/src/${i//./}"
        echo "DB name: magento${port_service_docker}"
    done
}

# check magento version installed
function check_magento_version_installed() {
	if [[ ! -z ${1} ]]; then
	    local magento_url=`get_magento_url_from_version ${1}`
	    RESPONSE=`bash -c "curl -s ${magento_url}magento_version"`
	    if [[ ${RESPONSE:0:8} = "Magento/" ]]; then
	        echo 1
	    else
		    echo 0
		fi
	fi
}

# check repository docker hub exist
function docker_tag_exists() {
    curl --silent -f -lSL https://index.docker.io/v1/repositories/$1/tags/$2 > /dev/null
}