#!/bin/bash
tar xvf magento.tar.gz &> /dev/null
chmod -R 777 .
# wait for database
php mysql.php
# Install magento
php bin/magento setup:install --use-rewrites=1 \
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
    --admin-use-security-key=0

# Update config for testing
php bin/magento config:set cms/wysiwyg/enabled disabled
php bin/magento config:set admin/security/admin_account_sharing 1
php bin/magento config:set admin/security/session_lifetime 31536000
php bin/magento config:set admin/captcha/enable 0

php bin/magento deploy:mode:set developer
php bin/magento setup:static-content:deploy -f
