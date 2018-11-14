#!/usr/bin/env bash

source .env
MAGENTO_VERSION_ARRAY=(${MAGENTO_VERSIONES//,/ })

if [[ ! ${MAGENTO_EDITION} = 'CE' ]]; then
    exit
fi

function downloadMagentoSrc() {
    MAGENTO_DOWNLOAD_URL='http://pubfiles.nexcess.net/magento/ce-packages/magento2-'${1}'.tar.gz'
    if [[ ${SAMPLE_DATA} = '1' ]]; then
        MAGENTO_DOWNLOAD_URL='http://pubfiles.nexcess.net/magento/ce-packages/magento2-with-samples-'${1}'.tar.gz'
    fi

    MAGENTO_FILENAME='magento/magento2-'${1}'.tar.gz'
    if [[ ! -f  ${MAGENTO_FILENAME} ]]; then
        wget -O ${MAGENTO_FILENAME} ${MAGENTO_DOWNLOAD_URL}
    fi
}

for i in "${MAGENTO_VERSION_ARRAY[@]}"
do
    downloadMagentoSrc ${i}
done
