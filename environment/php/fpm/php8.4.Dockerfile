FROM php:8.4-fpm

ARG USER_UID=1000
ARG USER_GID=1000

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN apt-get update && apt-get install -y \
        make \
        librabbitmq-dev \
        autoconf \
        acl \
        libfcgi \
        file \
        gettext \
        gnupg \
        libzip-dev \
        libpq-dev \
        default-mysql-client \
        libfreetype-dev \
        libjpeg-dev \
        libpng-dev \
        libwebp-dev \
        libxml2-dev \
        libonig-dev \
        librdkafka-dev \
        && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
        gd \
        pdo_mysql \
        pdo_pgsql \
        zip \
        simplexml \
        mbstring \
    && pecl install amqp xdebug rdkafka \
    && docker-php-ext-enable amqp xdebug rdkafka \
    && rm -rf /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

RUN addgroup --gid ${USER_UID} app && adduser --uid ${USER_UID} --gid ${USER_UID} --shell /bin/sh app

WORKDIR /var/www/html

RUN chown -R app:app /var/www/html && chmod -R 777 /var/log && chmod -R 777 /var/run

CMD ["php-fpm"]
