FROM php:7.1-fpm-alpine3.7

ENV MEMCACHED_DEPS zlib-dev libmemcached-dev cyrus-sasl-dev \
	SWOOLE_VERSION=4.1.2 \
    REDIS_VERSION=4.0.2 \
RUN set -ex \
	&& cd /tmp \
	&& curl -SL "https://github.com/swoole/swoole-src/archive/v${SWOOLE_VERSION}.tar.gz" -o swoole.tar.gz \
	&& curl -SL "http://pecl.php.net/get/redis-${REDIS_VERSION}.tgz" -o redis.tgz \
	&& ls -alh \
	&& apk update \
	&& apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS \
	&& apk add --no-cache --update --virtual .memcached-deps $MEMCACHED_DEPS \
	&& pecl install memcached \
	&& echo "extension=memcached.so" > /usr/local/etc/php/conf.d/docker-php-ext-memcached.ini \
	# for swoole ext
	&& apk add --no-cache libaio \
		linux-headers \
		libaio-dev \
		openssl-dev \
		libstdc++ \
		librdkafka-dev \
	# php extension: redis
	&& pecl install redis.tgz \
	&& docker-php-ext-enable redis \
	# php extension: pdo_mysql
	&& docker-php-ext-install pdo_mysql \
	&& rm -rf /usr/share/php7 \
    && rm -rf /tmp/* \
    && apk del .memcached-deps .phpize-deps