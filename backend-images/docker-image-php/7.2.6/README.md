#关于PHP docker官方镜像

- 官方的Dockerfile是其git仓库https://github.com/docker-library/php下的Dockerfile-alpine.template文件，自己编写可参考着

- 当前使用版本7.2.6

- 官方将镜像容器内目录`/usr/local/etc/php`作为ini配置文件夹，并在该文件夹中建立了子文件夹`conf.d`来扫描额外的ini配置文件；

- 官方镜像会检查`/usr/local/etc`下有没有`php-fpm.d`文件夹，

  - 有的话，会将当前目录(`/usr/local/etc`)下`php-fpm.conf.default`文件中替换一些内容后存为`php-fpm.conf`在当前目录中。然后把`php-fpm.d`目录中的`www.conf.default`文件复制一份为`www.conf`

  - 没有的话会在当前位置新建一个`php-fpm.d`文件夹，并把当前文件夹中的`php-fpm.conf.default`复制一份到`php-fpm.d`文件夹中并命名为`www.conf`。同样在当前文件夹(`/usr/local/etc`)下建立`php-fpm.conf`文件，文件内容中会include子目录php-fpm.d中的conf文件。官方是将我们传统一个`php-fpm.conf`中的内容拆分多个块到php-fpm.d文件夹中了再include进来，因此继承该镜像时，只需要将自己写的整块的`php-fpm.conf`覆盖掉其默认的即可，暂时没必要将配置分块到子文件夹中。

- 官方设定运行fpm的用户为`www-data`，用户组为`www-data`；

- 官方镜像中已经指定EXPOSE 9000端口，即容器将监听9000端口。

- 官方镜像设置容器内`/var/www/html`为web根目录。

- 官方镜像中设置的ENTRYPOINT为exec形式的`["docker-php-entrypoint"]`，CMD为exec形式的`["php-fpm"]`，因此运行容器时执行的命令是`docker-php-entrypoint php-fpm`，其实现查看docker-php-entrypoint.sh脚本内容，其最终目的就是运行`php-fpm`这个命令，后面可以加参数，所以在继承的Dockerfile中或`docker run`时，可以加参数。如`docker run php -v`就是执行`php-fpm -v`。

- `/usr/local/bin`目录内存在docker-php-ext-* 文件和docker-php-entrypoint文件

- `error_log`和`access.log`位置在`/proc/self/fd/2`，这个位置应该和linux输出有关的东西，也和docker输出日志有关。

- 官方镜像在`/usr/local/etc/php-fpm.d`放置了一个名为`zz-docker.conf`的文件，该文件可以配置php与nginx或apache的通信方式为SOCKET，而不是TCP

# 关于本Dockerfile镜像

可查看Dockerfile知晓安装了哪些，没有设置的选项均默认使用官方镜像的配置。

## 修改

- 执行用户不使用官方的`www-data`，改为了`nobody`

# 关于php-fpm.conf配置

重点关注和修改后面的`pm`相关、`listen`相关值

`listen`使用sock方式时，需要通过编排模板创建一个卷，php服务上将这个卷挂到socket文件所在目录，nginx服务上将这个卷也挂到相同路径。如下示例
```yaml
services:
  php:
    volumes:
      - phpsocket:/dev/shm
  nginx:
    volumes:
      - phpsocket:/dev/shm
volumes:
  phpsocket:
```

# 关于php.ini配置

暂无，按之前客户机器上的php.ini配置，复制过来的

# 关于目录

本目录/php版本/php变种

> fpm变种

其他变种均基于该变种衍生

> xdebug变种

该变种基于fpm变种衍生，没有swoole，一般情况下是用于单元测试应的镜像（因为单元测试需要php安装xdebug扩展）。

## 一些坑

1. 使用php-fpm.sock通信时，监听mode需要是0666，否则nginx没有权限去连接。

2. docker下面，php-fpm.conf中的daemon需要为yes

3. php-fpm.conf的一些配置需要在对应的区块分组下面，即[www]和[global]这些区块其实是有作用的，把一个区块下的配置放到其他区块下会被php提示unknown entry 'xxx'

4. 一些log日志参照官方镜像输出到标准输出，以方便通过docker logs可以查看