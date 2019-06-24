FROM registry.cn-hangzhou.aliyuncs.com/hangjia/alpine:3.7

LABEL maintainer="zhuwei"

ENV PHP_VERSION=5.6.40 PHP_DIR=/usr/local/etc/php/5.6/ PATH=$PATH:/usr/local/etc/php/5.6/bin/:/usr/local/etc/php/5.6/sbin/ TZ=Asia/Shanghai LANG=C.UTF-8
COPY php-5.6.40.tar.gz  /tmp/php-5.6.40.tar.gz
COPY libiconv-1.15.tar.gz /tmp/libiconv-1.15.tar.gz
COPY php-fpm.conf /tmp/php-fpm.conf
#config参数设置
RUN  CONFIG="\
		--prefix=/usr/local/etc/php/5.6 \
		--with-config-file-path=/usr/local/etc/php/5.6/etc \
		--with-gd \
		--with-mysql \
		--with-mysqli \
		--with-pdo-mysql  \
		--with-libxml-dir \
		--with-png-dir \
		--with-jpeg-dir \
		--with-zlib \
		--with-freetype-dir \
		--with-bz2 \
		--with-curl \
		--with-mcrypt --with-openssl \
		--with-mhash \
		--with-gettext \
		--with-xmlrpc \
		--enable-soap \
		--enable-mbstring=all \
		--enable-sockets \
		--enable-shared \
		--enable-gd-native-ttf \
		--enable-zip \
		--enable-xml \
		--enable-fpm \
		--enable-inline-optimization \
		--enable-pcntl \
		--enable-bcmath \
		--enable-calendar \
		--with-mysqli=mysqlnd \
		--with-pdo-mysql=mysqlnd \
		--enable-shmop \
		--enable-sysvsem \
		--enable-mbregex \
		--enable-short-tags \
		--with-iconv=/usr/local/etc/php/5.6/libiconv/ \
	" \
	#安装环境
	&& apk add  --no-cache --virtual mypacks \
		autoconf \	
		file \
		g++ \
		gcc \
		make \
		pkgconf \
		re2c \
		coreutils \
	&& apk add --no-cache \	
		libc-dev \
		dpkg \
		dpkg-dev \
		curl-dev \
		libedit-dev \
		libxml2-dev \
		libressl-dev \
		sqlite-dev \
		gettext-dev \
		bzip2-dev \
		jpeg-dev \
		libpng-dev \
		freetype-dev \
		libmcrypt-dev \
		tzdata \
		bash \
	&& wget -c --tries=0 https://pecl.php.net/get/solr-2.4.0.tgz -O /tmp/solr-2.4.0.tgz \
	&& wget -c --tries=0 https://pecl.php.net/get/redis-4.2.0.tgz -O /tmp/redis-4.2.0.tgz \
	&& wget -c --tries=0 https://pecl.php.net/get/memcache-2.2.7.tgz -O /tmp/memcache-2.2.7.tgz \
	&& wget -c --tries=0 https://xdebug.org/files/xdebug-2.5.0rc1.tgz  -O /tmp/xdebug-2.5.0rc1.tgz \
	&& cd /tmp \
	&& for tar in *.gz;  do tar xvf $tar -C /tmp; done \
	&& for tar in *.tgz;  do tar xvf $tar -C /tmp; done \
	#创建安装文件夹和启动用户，启动用户在php-fpm.conf设置，php-fpm.conf和php.ini通过挂载到镜像中使用
	&& mkdir -p /usr/local/etc/php/5.6 \
	&& addgroup -g 1002 -S ngvod \
	&& adduser ngvod -D -G ngvod -u 1002 -s /sbin/nologin \
	#安装libiconv
	&& cd /tmp/libiconv-1.15/ \
	&& ./configure --prefix=/usr/local/etc/php/5.6/libiconv/ \
	&& make \
	&& make install \
	#安装PHP
	&& cd /tmp/php-5.6.40 \
	&& ./configure $CONFIG \
	&& make \
	&& make install \
	&& mv /tmp/php-fpm.conf /usr/local/etc/php/5.6/etc/php-fpm.conf \
	#docker要把daemonizes设置为no,默认是yes的
	#安装ftp扩展
	&& cd /tmp/php-5.6.40/ext/ftp/ \
	&& /usr/local/etc/php/5.6/bin/phpize \
	&& ./configure --with-php-config=/usr/local/etc/php/5.6/bin/php-config --enable-ftp \
	&& make \
	&& make install \
	#xdebug
	&& cd /tmp/xdebug-2.5.0RC1 \
	&& /usr/local/etc/php/5.6/bin/phpize \
	&& ./configure --with-php-config=/usr/local/etc/php/5.6/bin/php-config \
	&& make \
	&& make install \
	&& cp -p modules/xdebug.so  /usr/local/etc/php/5.6/lib/php/extensions/no-debug-non-zts-20131226/xdebug.so \
	#安装redis扩展
	&& cd /tmp/redis-4.2.0 \
	&& /usr/local/etc/php/5.6/bin/phpize \
	&& ./configure --with-php-config=/usr/local/etc/php/5.6/bin/php-config \
	&& make \
	&& make install \
	#安装solr扩展
	&& cd /tmp/solr-2.4.0 \
	&& /usr/local/etc/php/5.6/bin/phpize \
	&& ./configure --with-php-config=/usr/local/etc/php/5.6/bin/php-config \
	&& make \
	&& make install \
	#安装memcache扩展，版本选择稳定版的，3.0.x测试版5.6的PHP用不了
	&& cd /tmp/memcache-2.2.7 \
	&& /usr/local/etc/php/5.6/bin/phpize \
	&& ./configure --with-php-config=/usr/local/etc/php/5.6/bin/php-config \
	&& make \
	&& make install \
	#安装composer
	&& wget -c --tries=0 https://getcomposer.org/download/1.8.0/composer.phar -O /usr/sbin/composer \
	&& chmod +x /usr/sbin/composer \
	&& rm -rf /tmp/* \
	&& ln -s /usr/local/etc/php/5.6/sbin/php-fpm /usr/sbin/php-fpm \
	##apk del mypacks删掉虚拟组包，能使容器小很多
	&& apk del mypacks

COPY php.ini /usr/local/etc/php/5.6/etc/		
EXPOSE 9000
WORKDIR /usr/local/etc/php/5.6/

STOPSIGNAL SIGTERM

CMD ["php-fpm", "-g", "daemon off;"]
