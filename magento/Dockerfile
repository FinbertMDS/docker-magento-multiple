FROM php:7.1-apache

# php extensions to run Magento
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libxslt1-dev \
        libicu-dev \
        zlib1g-dev \
        curl \
        git \
    && docker-php-ext-install -j$(nproc) mcrypt xsl intl pdo_mysql soap zip opcache bcmath \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Enable apache modes
RUN a2enmod rewrite
RUN a2enmod headers
RUN a2enmod ssl

# SSL
COPY server.crt /etc/ssl/certs/ssl-cert-snakeoil.pem
COPY server.key /etc/ssl/private/ssl-cert-snakeoil.key
RUN a2ensite default-ssl.conf

# Fix permission denied of execute files
RUN chmod +x /usr/local/bin/docker-php-entrypoint

# Expose ports
EXPOSE 80 443

# Back
COPY run-apache /usr/local/bin/
RUN chmod +x /usr/local/bin/run-apache

COPY conf/php.ini /usr/local/etc/php/conf.d/

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN chmod +x /usr/local/bin/composer

CMD ["run-apache"]
WORKDIR /var/www/html
