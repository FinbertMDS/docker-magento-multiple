#!/usr/bin/env bash

php bin/magento setup:upgrade
php bin/magento setup:di:compile
php bin/magento webpos:deploy