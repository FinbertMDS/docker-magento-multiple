#!/usr/bin/env bash

source bin/common.sh

function validate_install_pwa_studio() {
    if [[ ${INSTALL_PWA_STUDIO} = '1' ]]; then
        local line_number_sample_data=`awk '/SAMPLE_DATA/{ print NR; exit }' .env`
        exec_cmd "sed -i '${line_number_sample_data}s/.*/SAMPLE_DATA=0 # install magento with sample data/' .env"
        echo ${MAGENTO_VERSION_ARRAY[0]}
        local version_compare_result=`version_compare ${MAGENTO_VERSION_ARRAY[0]} '2.3.0' '<'`
        if [[ ${version_compare_result} = '1' ]]; then
            local line_number_magento_version=`awk '/MAGENTO_VERSIONES/{ print NR; exit }' .env`
            exec_cmd "sed -i '${line_number_magento_version}s/.*/MAGENTO_VERSIONES=2.3.0/' .env"
        fi
        source .env
    fi
}

function prepare_environment_for_once_version_magento() {
    if [[ ${#MAGENTO_VERSION_ARRAY[@]} = 1 ]]; then
        if [[ -f docker-compose.yml ]]; then
		    local docker_hub_name="ngovanhuy0241/docker-magento-multiple-db"
		    local docker_hub_tag_name="${MAGENTO_VERSION_ARRAY[0]}"
		    if [[ ${is_install_pwa_studio} = '1' ]]; then
		        docker_hub_tag_name="${MAGENTO_VERSION_ARRAY[0]}-pwa"
            fi
		    if docker_tag_exists ${docker_hub_name} ${docker_hub_tag_name} ; then
	            local line_number_image_name_db=`awk '/# image_name_db/{ print NR; exit }' docker-compose.yml`
	            if [[ ! -z ${line_number_image_name_db} ]]; then
	                local is_install_pwa_studio=`check_install_pwa_studio ${MAGENTO_VERSION_ARRAY[0]}`
	                if [[ ${is_install_pwa_studio} = '1' ]]; then
	                    exec_cmd "sed -i '${line_number_image_name_db}s/.*/    image: ngovanhuy0241\/docker-magento-multiple-db:${MAGENTO_VERSION_ARRAY[0]}-pwa # image_name_db/' docker-compose.yml"
	                else
	                    exec_cmd "sed -i '${line_number_image_name_db}s/.*/    image: ngovanhuy0241\/docker-magento-multiple-db:${MAGENTO_VERSION_ARRAY[0]} # image_name_db/' docker-compose.yml"
	                fi
	            fi
			fi
        fi
    fi
}

# init file data/prepare_data/database.sql dynamic by magento version
function prepare_init_database_sql() {
    print_status 'Init file data/init_data/database.sql...'
    local init_database_file='data/init_data/database.sql'
    rm -f ${init_database_file}
    touch ${init_database_file}
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        local port_service_docker=`get_port_service_docker "${i}"`
        local init_database_string='CREATE DATABASE IF NOT EXISTS magento'${port_service_docker}';'
        echo ${init_database_string} >> ${init_database_file}
    done
    print_done
}

# remove all persist data
function remove_persist_data() {
    print_status "Remove persist data..."
    rm -rf data/init_data
#    sudo rm -rf data/mysql
#    sudo rm -rf src/*
	for directory in src/*; do
	  if [[ -d "${directory}" ]]; then
	    local is_folder_magento_version=0
	    for i in "${MAGENTO_VERSION_ARRAY[@]}"
	    do
            local magento_version="${i//./}"
            if [[ ${directory} == *"${magento_version}"* ]]; then
		        local magento_installed_flag=`check_magento_version_installed ${i}`
		        if [[ ${magento_installed_flag} = '1' ]]; then
		            is_folder_magento_version=1
		        fi
            fi
	    done
	    if [[ ${is_folder_magento_version} = '0' ]]; then
			echo -ne "Removing folder: $directory..."
	        sudo rm -rf "$directory"
			echo "Done."
	    fi
	  fi
	done
    print_done
}

# init folder persist data
function init_folder_persist_data_docker() {
    print_status "Init folder to persist data docker..."
    mkdir -p data/mysql
    mkdir -p src
    mkdir -p data/init_data/
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        local magento_folder_src='src/'"${i//./}"
        mkdir -p ${magento_folder_src}
    done
    print_done
}

# prepare file mysql to import to database
function prepare_sql_import_db() {
    print_status "Init sql to import to databases..."
    local mysql_init_data_folder='data/init_data/'
    if [[ ${#MAGENTO_VERSION_ARRAY[@]} != 1 ]]; then
        for i in "${MAGENTO_VERSION_ARRAY[@]}"
        do
            local mysql_filename='data/prepare_data/'${i}'.sql'
            if [[ -f ${mysql_filename} ]]; then
                cp ${mysql_filename} ${mysql_init_data_folder}${i}'.sql'
            fi
        done
    fi
    print_done
}

# check add file tar.gz of all version magento existed
function copy_file_install_magento() {
    print_status "Copy source code magento and file install magento to volume docker..."
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        local magento_version=`get_version_magento ${i}`
        local magento_filename_src="magento${magento_version}-${i}.tar.gz"
        if [[ ${SAMPLE_DATA} = '1' ]]; then
            if [[ ${magento_version} = '2' ]]; then
                magento_filename_src="magento${magento_version}-with-samples-${i}.tar.gz"
            fi
        fi

        if [[ ! -f 'magento/'${magento_filename_src} ]]; then
          echo "Please place file ${magento_filename_src} at folder magento"
          exit
        fi
        local magento_folder_src='src/'"${i//./}"
        if [[ ! -f ${magento_folder_src}${magento_filename_src} ]]; then
            cp 'magento/'${magento_filename_src} ${magento_folder_src}'/magento.tar.gz'
        fi
        if [[ ${SAMPLE_DATA} = '1' ]]; then
            if [[ ${magento_version} = '1' ]]; then
                local magento_sample_data_version=`get_version_sample_data_magento1 ${i}`
                local magento_sample_filename='magento/magento1-sample-data-'${magento_sample_data_version}'.tar.gz'
                cp ${magento_sample_filename} ${magento_folder_src}'/magento-sample.tar.gz'
                tar xvf ${magento_folder_src}'/magento-sample.tar.gz' -C ${magento_folder_src} &> /dev/null
                rsync -av ${magento_folder_src}'/magento-sample-data-'${magento_sample_data_version}'/' ${magento_folder_src}'/' &> /dev/null
                rm -rf ${magento_folder_src}'/magento-sample-data-'${magento_sample_data_version}'/'
            fi
        fi
        cp 'magento/install_magento'${magento_version}'.sh' ${magento_folder_src}'/install_magento.sh'
        cp 'magento/install_pwa_pos_magestore.sh' ${magento_folder_src}'/'
        if [[ ${SAMPLE_DATA} = '0' ]]; then
            local VERSION_COMPARE_RESULT=`version_compare $1 '2.3.0' '<'`
            if [[ ${VERSION_COMPARE_RESULT} = '0' ]]; then
                if [[ ${INSTALL_PWA_STUDIO} = '1' ]]; then
                    cp "magento/deployVeniaSampleData.sh" ${magento_folder_src}'/'
                fi
            fi
        fi
        cp magento/mysql.php ${magento_folder_src}
    done
    print_done
}

function prepare_docker_compose_file() {
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        local php_version=`get_version_php "${i}"`
        local magento_version="${i//./}"
        local docker_compose_file='docker-compose-magento-'${i}'-php-'${php_version}'.yml'
        local magento_url=`get_magento_url_from_version "${i}"`
        local magento_db_name=`get_magento_db_name "${i}"`
        local port_service_docker=`get_port_service_docker "${i}"`
        local docker_hub_name="ngovanhuy0241/docker-magento-multiple-magento"
        local docker_hub_tag_name="magento${port_service_docker}"
        rm -f ${docker_compose_file}
        local docker_compose_service_magento="build:
      context: ./magento
      dockerfile: Dockerfile_image_${php_version}"
        if docker_tag_exists ${docker_hub_name} ${docker_hub_tag_name} ; then
            docker_compose_service_magento="#build:
#      context: ./magento
#      dockerfile: Dockerfile_image_${php_version}
    image: ngovanhuy0241/docker-magento-multiple-magento:magento${port_service_docker}"
		fi
cat >${docker_compose_file} <<EOL
version: '3'

services:
  ${docker_hub_tag_name}:
    ${docker_compose_service_magento}
#    container_name: docker-magento-multiple_magento_${i}_${php_version}_1
    restart: always
    ports:
      - ${port_service_docker}:80
    depends_on:
      - db
    environment:
      MAGENTO_URL: ${magento_url}
      MYSQL_DATABASE: ${magento_db_name}
    env_file:
      - .env
    volumes:
      - ./src/${magento_version}:/var/www/html
    networks:
      webnet:
networks:
  webnet:
EOL
    done
}

function install_nginx() {
    if ! which nginx > /dev/null 2>&1; then
        echo "Nginx installing ..."
        sudo apt update
        sudo apt install nginx -y
        sudo ufw allow 'Nginx Full'
        sudo service nginx restart
    fi
    echo "Nginx installed."
}

function prepare_nginx_config_file() {
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        local magento_version="${i//./}"
        local port_service_docker=`get_port_service_docker "${i}"`
        local nginx_magento_config_file="nginx/${i}-nginx-magento2-docker"
        local upstream_name="magento${magento_version}"
        local magento_url=`get_magento_host_name_from_version "${i}"`
        rm -f ${nginx_magento_config_file}
cat >${nginx_magento_config_file} <<EOL
upstream ${upstream_name} {
    server 127.0.0.1:${port_service_docker} weight=1;
}

server {
    listen 80;
    server_name ${magento_url};

    location / {
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_pass http://${upstream_name} ;
    }
}
EOL
    done
}

function copy_nginx_config_to_local() {
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        local nginx_magento_config_file_name="${i}-nginx-magento2-docker"
        local nginx_magento_config_file_source="nginx/${i}-nginx-magento2-docker"
        sudo rm -f "/etc/nginx/sites-available/${nginx_magento_config_file_name}"
        sudo rm -f "/etc/nginx/sites-enabled/${nginx_magento_config_file_name}"
        sudo cp ${nginx_magento_config_file_source} /etc/nginx/sites-available
        if [[ ! -f /etc/nginx/sites-enabled/${nginx_magento_config_file_name} ]]; then
            sudo ln -s /etc/nginx/sites-available/${nginx_magento_config_file_name} /etc/nginx/sites-enabled/
        fi
        sudo service nginx restart
    done
}

function main() {
    validate_install_pwa_studio
    prepare_environment_for_once_version_magento
    remove_persist_data
    init_folder_persist_data_docker
    prepare_init_database_sql
    prepare_sql_import_db
    copy_file_install_magento
    prepare_docker_compose_file
    if [[ ${INSTALL_MAGENTO_WITH_DOMAIN} = '1' ]]; then
	    install_nginx
	    prepare_nginx_config_file
	    copy_nginx_config_to_local
    fi
}

calculate_time_run_command main