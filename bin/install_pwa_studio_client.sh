#!/usr/bin/env bash

# Configuration magento backend url
magento_backend_url="http://magento23072.com/"

if [[ ! -d pwa-studio ]]; then
    git clone https://github.com/magento-research/pwa-studio.git
fi
cd pwa-studio

npm install

cp packages/venia-concept/.env.dist packages/venia-concept/.env

line_old='MAGENTO_BACKEND_URL="https://release-dev-rxvv2iq-zddsyhrdimyra.us-4.magentosite.cloud/"'
line_new='MAGENTO_BACKEND_URL="http://magento23072.com/"'
sed -i "s%$line_old%$line_new%g" packages/venia-concept/.env

echo 'Change value MAGENTO_BACKEND_URL="http://magento23072.com/" in packages/venia-concept/.env'
echo 'Build artifacts: npm run build'
npm run build
echo "Start server: npm run watch:venia"
npm run watch:venia

