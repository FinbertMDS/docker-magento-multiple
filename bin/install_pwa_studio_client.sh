#!/usr/bin/env bash

# Configuration magento backend url
magento_backend_url="http://magento23072.com/"

git clone https://github.com/magento-research/pwa-studio.git
cd pwa-studio

npm install

cp packages/venia-concept/.env.dist packages/venia-concept/.env
line_number_magento_backend_url=`awk '/MAGENTO_BACKEND_URL/{ print NR; exit }' packages/venia-concept/.env`
bash -c "sed -i '${line_number_magento_backend_url}s/.*/    ${magento_backend_url}' packages/venia-concept/.env"

npm run watch:all

