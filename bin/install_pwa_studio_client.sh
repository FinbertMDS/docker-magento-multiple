#!/usr/bin/env bash

# Configuration magento backend url
magento_backend_url="http://magento23072.com/"

if [[ ! -d pwa-studio ]]; then
    git clone https://github.com/magento-research/pwa-studio.git
fi
cd pwa-studio

npm install

cp packages/venia-concept/.env.dist packages/venia-concept/.env

echo "Change value MAGENTO_BACKEND_URL in packages/venia-concept/.env"
echo "Start server: npm run watch:venia"
#npm run watch:venia

