#!/bin/bash
chmod -R 777 .
chown -R www-data:www-data .
tar xvf magento.tar.gz &> /dev/null
chmod -R 777 .
# wait for database
php mysql.php
# Install magento
install_magento="php bin/magento setup:install --use-rewrites=1 \
    --db-host=$MYSQL_HOST \
    --db-name=$MYSQL_DATABASE \
    --db-password=$MYSQL_ROOT_PASSWORD \
    --admin-firstname=$MAGENTO_ADMIN_FIRSTNAME \
    --admin-lastname=$MAGENTO_ADMIN_LASTNAME \
    --admin-email=$MAGENTO_ADMIN_EMAIL \
    --admin-user=$MAGENTO_ADMIN_USERNAME \
    --admin-password=$MAGENTO_ADMIN_PASSWORD \
    --base-url=$MAGENTO_URL \
    --backend-frontname=admin \
    --language=$MAGENTO_LOCALE \
    --currency=$MAGENTO_DEFAULT_CURRENCY \
    --timezone=$MAGENTO_TIMEZONE \
    --use-rewrites=1 \
    --admin-use-security-key=0 "

if [[ ${INSTALL_RABBIT_MQ} = '1' ]]; then
    install_magento=${install_magento}" --amqp-host=rabbitmq --amqp-port=5672 --amqp-user=$RABBITMQ_DEFAULT_USER --amqp-password=$RABBITMQ_DEFAULT_PASS --amqp-virtualhost=$RABBITMQ_DEFAULT_VHOST "
fi

eval ${install_magento}

# Update config for testing
php bin/magento config:set cms/wysiwyg/enabled disabled
php bin/magento config:set admin/security/admin_account_sharing 1
php bin/magento config:set admin/security/session_lifetime 31536000
php bin/magento config:set admin/captcha/enable 0

php bin/magento deploy:mode:set developer
php bin/magento setup:static-content:deploy -f

# Setup cron
php bin/magento cron:install --force
