#!/usr/bin/env bash
chmod -R 777 ..
chowm -R www-data:www-data ..
tar xvf magento.tar.gz &> /dev/null
rsync -av magento/ . &> /dev/null
rm -rf magento/
chmod -R 777 .
# wait for database
php mysql.php
# Install magento
php -f install.php -- --license_agreement_accepted yes \
    --locale $MAGENTO_LOCALE --timezone $MAGENTO_TIMEZONE --default_currency $MAGENTO_DEFAULT_CURRENCY \
    --db_host $MYSQL_HOST --db_name $MYSQL_DATABASE --db_user "root" --db_pass $MYSQL_ROOT_PASSWORD \
    --url $MAGENTO_URL --skip_url_validation yes --use_rewrites yes \
    --use_secure no --secure_base_url "" --use_secure_admin no \
    --admin_firstname $MAGENTO_ADMIN_FIRSTNAME --admin_lastname $MAGENTO_ADMIN_LASTNAME \
    --admin_email $MAGENTO_ADMIN_EMAIL --admin_username $MAGENTO_ADMIN_USERNAME \
    --admin_password $MAGENTO_ADMIN_PASSWORD