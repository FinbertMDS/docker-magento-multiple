#!/usr/bin/env bash
tar xvf magento.tar.gz &> /dev/null
tar xvf magento-sample.tar.gz &> /dev/null
chmod -R 777 ./
# wait for database
php mysql.php
# Install magento
php -f install.php -- --license_agreement_accepted yes \
    --use_rewrites yes \
    --locale $MAGENTO_LOCALE \
    --timezone $MAGENTO_TIMEZONE \
    --default_currency $MAGENTO_DEFAULT_CURRENCY \
    --db_host $MYSQL_HOST \
    --db_name $MYSQL_DATABASE \
    --db_user $MYSQL_USER \
    --db_pass $MYSQL_PASSWORD \
    --url $MAGENTO_URL \
    --admin_firstname $MAGENTO_ADMIN_FIRSTNAME \
    --admin_lastname $MAGENTO_ADMIN_LASTNAME \
    --admin_email $MAGENTO_ADMIN_EMAIL \
    --admin_username $MAGENTO_ADMIN_USERNAME \
    --admin_password $MAGENTO_ADMIN_PASSWORD