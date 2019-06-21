FROM php:5.6.37-fpm-alpine3.7
COPY memcache-2.2.7.tgz /tmp/memcache-2.2.7.tgz
ADD composer.phar /usr/sbin/composer
COPY php.ini /usr/local/etc/php/
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update \
	&& apk add --no-cache --update libmcrypt-dev freetype-dev libjpeg-turbo-dev  libmemcached-libs zlib autoconf sed gcc g++ make \
	&& docker-php-ext-install mcrypt pdo_mysql \
	&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
	&& mkdir -p /usr/src/php/ext/redis \
    && curl -L https://github.com/phpredis/phpredis/archive/3.1.6.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && echo 'redis' >> /usr/src/php-available-exts \
    && docker-php-ext-install redis \
    #memcache
    && cd /tmp \
	&& for tar in *.tgz;  do tar xvf $tar -C /tmp; done \
    && cd /tmp/memcache-2.2.7 \
	&& /usr/local/bin/phpize \
	&& ./configure --with-php-config=/usr/local/bin/php-config \
	&& make \
	&& make install \
    #composer
	&& chmod +x /usr/sbin/composer \
    && rm -rf /tmp/*