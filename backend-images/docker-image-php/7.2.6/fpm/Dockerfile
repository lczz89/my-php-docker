FROM registry.cn-hangzhou.aliyuncs.com/hangjia/alpine:3.7

ARG PHP_VERSION

# 安装phpize需要的依赖
# these get automatically installed and removed by "docker-php-ext-*" (unless they're already installed)
ENV PHPIZE_DEPS \
		autoconf \
		dpkg-dev dpkg \
		file \
		g++ \
		gcc \
		libc-dev \
		make \
		pkgconf \
		re2c

# 对alpine安装环境依赖
RUN apk add --no-cache --virtual .persistent-deps \
		ca-certificates \
		curl \
		tar \
		xz \
		libressl

# 官方镜像会创建执行用户
# RUN set -x \
# 	&& addgroup -g 82 -S www-data \
# 	&& adduser -u 82 -D -S -G www-data www-data

ENV PHP_INI_DIR /usr/local/etc/php
RUN mkdir -p $PHP_INI_DIR/conf.d

# ENV PHP_EXTRA_CONFIGURE_ARGS --enable-fpm --with-fpm-user=nobody --with-fpm-group=nobody
# 执行用户和分组可以在php-fpm.conf中进行设置，而不在编译中
ENV PHP_EXTRA_CONFIGURE_ARGS --enable-fpm

# 抄官方的https://github.com/docker-library/php/issues/272
ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie"

ENV PHP_VERSION ${PHP_VERSION}
# ENV PHP_URL="http://cn2.php.net/get/php-7.2.6.tar.xz/from/this/mirror"

RUN set -xe; \
	\
	mkdir -p /usr/src; \
	cd /usr/src;
	#wget -O php.tar.xz "$PHP_URL";

COPY php-7.2.6.tar.xz /usr/src/php.tar.xz
COPY pecl/ /usr/src/pecl/
COPY docker-php-source /usr/local/bin/
COPY docker-php-ext-* docker-php-entrypoint /usr/local/bin/
RUN chmod 777 /usr/local/bin/docker-php-*

RUN set -xe \
	&& apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
		coreutils \
		curl-dev \
		libedit-dev \
		libressl-dev \
		libsodium-dev \
		libxml2-dev \
		sqlite-dev \
		zlib-dev \
	&& export CFLAGS="$PHP_CFLAGS" \
		CPPFLAGS="$PHP_CPPFLAGS" \
		LDFLAGS="$PHP_LDFLAGS" \
	#解压php压缩包到/usr/src/php
	&& docker-php-source extract \
	&& cd /usr/src/php \
	#dpkg-architecture --query DEB_BUILD_GNU_TYPE得到类似"x86_64-linux-*"字符串
	&& gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
	&& ./configure \
		--build="$gnuArch" \
		--with-config-file-path="$PHP_INI_DIR" \
		--with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
		\
# make sure invalid --configure-flags are fatal errors intead of just warnings
		--enable-option-checking=fatal \
		\
		--disable-cgi \
		\
# https://github.com/docker-library/php/issues/439
		--with-mhash \
		\
# --enable-ftp is included here because ftp_ssl_connect() needs ftp to be compiled statically (see https://github.com/docker-library/php/issues/236)
		--enable-ftp \
# --enable-mbstring is included here because otherwise there's no way to get pecl to use it properly (see https://github.com/docker-library/php/issues/195)
		--enable-mbstring \
# --enable-mysqlnd is included here because it's harder to compile after the fact than extensions are (since it's a plugin for several extensions, not an extension in itself)
		--enable-mysqlnd \
# https://wiki.php.net/rfc/libsodium
		--with-sodium=shared \
		\
		--with-curl \
		--with-libedit \
		--with-openssl \
		--with-zlib \
		\
# bundled pcre does not support JIT on s390x
# https://manpages.debian.org/stretch/libpcre3-dev/pcrejit.3.en.html#AVAILABILITY_OF_JIT_SUPPORT
		$(test "$gnuArch" = 's390x-linux-gnu' && echo '--without-pcre-jit') \
		\
		$PHP_EXTRA_CONFIGURE_ARGS \
	&& make -j "$(nproc)" \
	&& make install \
	#对一些指定文件执行strip脱衣服，使得文件变小
	&& { find /usr/local/bin /usr/local/sbin -type f -perm +0111 -exec strip --strip-all '{}' + || true; } \
	&& make clean \
	&& cd / \
	&& docker-php-source delete \
	\
	&& pecl update-channels pecl.php.net \
	# 获得所依赖的运行库的列表，减少安装依赖
	&& runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)" \
	&& apk add --no-cache --virtual .php-rundeps $runDeps \
		libevent-dev \
		libmemcached-dev \
# https://github.com/docker-library/php/issues/443
	&& rm -rf /tmp/pear ~/.pearrc


# sodium was built as a shared module (so that it can be replaced later if so desired), so let's enable it too (https://github.com/docker-library/php/issues/598)
RUN docker-php-ext-enable sodium

# 安装必要扩展
RUN docker-php-ext-install pdo pdo_mysql pcntl zip

# pecl不稳定，采用本地安装
RUN cd /usr/src/pecl \
	&& pecl install igbinary* \
	# && pecl install msgpack \
	&& pecl install redis* \
	&& /bin/bash -c '/bin/echo -e "\n\n\nyes\nno\nyes\nyes\nyes\nyes\n" | pecl install /usr/src/pecl/memcached*' \
	&& docker-php-ext-enable igbinary redis memcached

# 这一句放在最后，alpine都是虚拟包安装方式，装完后运行这一句会删掉虚拟包以节省空间，导致无法安装其他扩展等
RUN apk del .build-deps

ENTRYPOINT ["docker-php-entrypoint"]

WORKDIR /var/www/html

# 将已经准备好的php-fpm.conf放进来到/usr/local/etc，替换掉官方的做法

COPY php-fpm.conf /usr/local/etc/php-fpm.conf

EXPOSE 9000
CMD ["php-fpm"]
