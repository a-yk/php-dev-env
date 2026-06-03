FROM php:7.4-fpm

ARG USER_UID=1000
ARG USER_GID=1000

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
        libonig-dev

RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
        gd \
        pdo_mysql \
        pdo_pgsql \
        zip \
        simplexml \
        mbstring \
    && pecl install amqp xdebug-3.1.5 \
    && docker-php-ext-enable amqp xdebug

RUN addgroup --gid ${USER_UID} app && adduser --uid ${USER_UID} --gid ${USER_UID} --shell /bin/sh app

WORKDIR /var/www/html

RUN chown -R app:app /var/www/html && chmod -R 777 /var/log && chmod -R 777 /var/run

CMD ["php-fpm"]
