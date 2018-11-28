#!/usr/bin/env bash

source bin/common.sh

if [[ ! ${MAGENTO_EDITION} = 'CE' ]]; then
    exit
fi

function get_magento_sample_data_download_url() {
    magento_sample_data_download_url='https://nchc.dl.sourceforge.net/project/mageloads/assets/'${1}'/magento-sample-data-'${1}'.tar.gz'

    if [[ ${1} = '1.9.2.4' ]]; then
        magento_sample_data_download_url='https://nchc.dl.sourceforge.net/project/mageloads/assets/1.9.2.4/magento-sample-data-1.9.2.4-fix.tar.gz'
    fi
    echo ${magento_sample_data_download_url}
}

function download_magento1() {
    magento_download_url='http://pubfiles.nexcess.net/magento/ce-packages/magento-'${1}'.tar.gz'
    magento_sample_data_version=`get_version_sample_data_magento1 ${1}`
    magento_sample_data_download_url=`get_magento_sample_data_download_url ${magento_sample_data_version}`

    local magento_filename='magento/magento1-'${1}'.tar.gz'
    local magento_sample_filename='magento/magento1-sample-data-'${magento_sample_data_version}'.tar.gz'
    if [[ ! -f  ${magento_filename} ]]; then
        wget -O ${magento_filename} ${magento_download_url}
    fi
    if [[ ! -f  ${magento_sample_filename} ]]; then
        if [[ ${SAMPLE_DATA} = '1' ]]; then
                wget -O ${magento_sample_filename} ${magento_sample_data_download_url}
        fi
    fi
}

function download_magento2() {
    local magento_download_url='http://pubfiles.nexcess.net/magento/ce-packages/magento2-'${1}'.tar.gz'
    if [[ ${SAMPLE_DATA} = '1' ]]; then
        magento_download_url='http://pubfiles.nexcess.net/magento/ce-packages/magento2-with-samples-'${1}'.tar.gz'
    fi

    local magento_filename='magento/magento2-'${1}'.tar.gz'
    if [[ ! -f  ${magento_filename} ]]; then
        wget -O ${magento_filename} ${magento_download_url}
    fi
}

function download_magento() {
    if [[ ${1} == 2.* ]]; then
        download_magento2 $1
    elif [[ ${1} == 1.* ]]; then
        download_magento1 $1
    fi
}

function main() {
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        download_magento ${i}
    done
}

calculate_time_run_command main