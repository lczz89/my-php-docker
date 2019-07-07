ARG PHP_VERSION
FROM registry.cn-hangzhou.aliyuncs.com/hangjia/php:${PHP_VERSION}-fpm

COPY pecl/ /usr/src/pel/

RUN apk add --no-cache $PHPIZE_DEPS \
    && pecl install /usr/src/pel/xdebug* \
    && docker-php-ext-enable xdebug

WORKDIR /var/www/html