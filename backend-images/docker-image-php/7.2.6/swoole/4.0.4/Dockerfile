ARG PHP_VERSION
FROM registry.cn-hangzhou.aliyuncs.com/hangjia/php:${PHP_VERSION}-fpm

# 安装依赖
RUN set -xe \
	&& apk add --no-cache --virtual .build-deps \
	autoconf \
	libressl-dev \
	make \
    g++ \
    libc-dev

# gcc删了会导致swoole模块加载不了；不要删除的一些模块
RUN apk add --no-cache nghttp2-dev gcc pcre-dev

RUN docker-php-ext-install sockets

# install hiredis

RUN cd /root && \
    curl -o /tmp/hiredis.tar.gz https://github.com/redis/hiredis/archive/v0.13.3.tar.gz -L && \
    tar zxvf /tmp/hiredis.tar.gz && cd hiredis-* && \
    make && make install


# install swoole
RUN cd /root && \
    curl -o /tmp/swoole.tar.gz https://github.com/swoole/swoole-src/archive/v4.0.4.tar.gz -L && \
    tar zxvf /tmp/swoole.tar.gz && cd swoole-src* && \
    phpize && \
    ./configure \
    # --enable-coroutine \ 4.0.1之后不需要再设置该参数
    --enable-openssl  \
    --enable-http2  \
    --enable-async-redis \
    --enable-sockets \
    --enable-mysqlnd && \
    make && make install && \
    docker-php-ext-enable swoole && \
    # echo "swoole.fast_serialize=On" >> /usr/local/etc/php/conf.d/docker-php-ext-swoole-serialize.ini && \
    rm -rf /tmp/*

RUN apk del .build-deps