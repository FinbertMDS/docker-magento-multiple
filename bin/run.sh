#!/usr/bin/env bash

source bin/common.sh

function run_docker() {
    local docker_build_command=`get_docker_command "up -d"`
    exec_cmd "${docker_build_command}"
}

function run_sql_init_database() {
    local init_database_file='data/init_data/database.sql'
    local docker_container_name_db='docker-magento-multiple_db_1'
    exec_cmd "until docker exec -it ${docker_container_name_db} bash -c 'mysql --user=root --password=${MYSQL_ROOT_PASSWORD} --execute \"SHOW DATABASES;\"' > /dev/null 2>&1; do sleep 2; done"
    exec_cmd "docker cp ${init_database_file} ${docker_container_name_db}:/docker-entrypoint-initdb.d/database.sql"
    exec_cmd "docker exec ${docker_container_name_db} bash -c 'mysql -u root --password=${MYSQL_ROOT_PASSWORD} < docker-entrypoint-initdb.d/database.sql'"
}

function install_magento() {
    local php_version=`get_version_php ${1}`
    if [[ ! -z ${php_version} ]]; then
        local docker_container_name="docker-magento-multiple_magento_"${1}"_"${php_version}"_1"
        local magento_version=`get_version_magento ${1}`
        if [[ ${magento_version} = '2' ]]; then
            if [[ ${INSTALL_CRON} = '1' ]]; then
                exec_cmd 'docker exec '${docker_container_name}' bash -c "service cron start"'
            fi
#TODO : add multiple line to file .htaccess in Magento 2 to use PWA POS
#Header always set Access-Control-Allow-Origin "*"
#Header always set Access-Control-Allow-Methods "POST, GET, OPTIONS, DELETE, PUT"
#Header always set Access-Control-Max-Age "1000"
#Header always set Access-Control-Allow-Headers "x-requested-with, Content-Type, origin, authorization, accept, client-security-token"
#
#RewriteEngine On
#RewriteCond %{REQUEST_METHOD} OPTIONS
#RewriteRule ^(.*)$ $1 [R=200,L]
        fi
#TODO : uncomment line at file .htaccess in Magento 1 to use Web POS
#        Options -MultiViews
        docker exec ${docker_container_name} bash -c "chown -R www-data:www-data .. && chmod -R 777 .."
        docker exec -u www-data ${docker_container_name} bash -c "./install_magento.sh"
        local is_install_pwa_studio=`check_install_pwa_studio ${1}`
        if [[ ${is_install_pwa_studio} = '1' ]]; then
            docker exec -u www-data ${docker_container_name} bash -c "composer update"
            docker exec -u www-data ${docker_container_name} bash -c "./deployVeniaSampleData.sh --yes"
            docker exec -u www-data ${docker_container_name} bash -c "php bin/magento setup:upgrade"
        fi
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
        local magento_version="${i//./}"
        exec_cmd "grep -q -F '127.0.0.1 m${magento_version}.io' /etc/hosts || echo '127.0.0.1 m${magento_version}.io' | sudo tee --append /etc/hosts > /dev/null"
    done
    print_done
}

function main() {
    curl_check
    run_docker
    run_sql_init_database
    install_magento_for_all_containers
    add_host_to_local
    print_site_magento_list
}

calculate_time_run_command main