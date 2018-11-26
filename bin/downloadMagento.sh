#!/usr/bin/env bash

source bin/common.sh

if [[ ! ${MAGENTO_EDITION} = 'CE' ]]; then
    exit
fi

function get_magento_sample_data_download_url() {
    MAGENTO_SAMPLE_DATA_DOWNLOAD_URL='https://nchc.dl.sourceforge.net/project/mageloads/assets/'${1}'/magento-sample-data-'${1}'.tar.gz'

    if [[ ${1} = '1.9.2.4' ]]; then
        MAGENTO_SAMPLE_DATA_DOWNLOAD_URL='https://nchc.dl.sourceforge.net/project/mageloads/assets/1.9.2.4/magento-sample-data-1.9.2.4-fix.tar.gz'
    fi
    echo ${MAGENTO_SAMPLE_DATA_DOWNLOAD_URL}
}

function download_magento1() {
    MAGENTO_DOWNLOAD_URL='http://pubfiles.nexcess.net/magento/ce-packages/magento-'${1}'.tar.gz'
    MAGENTO_SAMPLE_DATA_VERSION=`get_version_sample_data_magento1 ${1}`
    MAGENTO_SAMPLE_DATA_DOWNLOAD_URL=`get_magento_sample_data_download_url ${MAGENTO_SAMPLE_DATA_VERSION}`

    local MAGENTO_FILENAME='magento/magento1-'${1}'.tar.gz'
    local MAGENTO_SAMPLE_FILENAME='magento/magento1-sample-data-'${MAGENTO_SAMPLE_DATA_VERSION}'.tar.gz'
    if [[ ! -f  ${MAGENTO_FILENAME} ]]; then
        wget -O ${MAGENTO_FILENAME} ${MAGENTO_DOWNLOAD_URL}
    fi
    if [[ ! -f  ${MAGENTO_SAMPLE_FILENAME} ]]; then
        if [[ ${SAMPLE_DATA} = '1' ]]; then
                wget -O ${MAGENTO_SAMPLE_FILENAME} ${MAGENTO_SAMPLE_DATA_DOWNLOAD_URL}
        fi
    fi
}

function download_magento2() {
    local MAGENTO_DOWNLOAD_URL='http://pubfiles.nexcess.net/magento/ce-packages/magento2-'${1}'.tar.gz'
    if [[ ${SAMPLE_DATA} = '1' ]]; then
        MAGENTO_DOWNLOAD_URL='http://pubfiles.nexcess.net/magento/ce-packages/magento2-with-samples-'${1}'.tar.gz'
    fi

    local MAGENTO_FILENAME='magento/magento2-'${1}'.tar.gz'
    if [[ ! -f  ${MAGENTO_FILENAME} ]]; then
        wget -O ${MAGENTO_FILENAME} ${MAGENTO_DOWNLOAD_URL}
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