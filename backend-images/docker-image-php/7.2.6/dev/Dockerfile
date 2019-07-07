FROM registry.cn-hangzhou.aliyuncs.com/hangjia/php:7.2.6-fpm

#安装composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer config -g repo.packagist composer https://packagist.phpcomposer.com
#RUN composer self-update --clean-backups