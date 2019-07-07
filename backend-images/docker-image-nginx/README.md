#关于nginx docker官方镜像

- 官方镜像默认静态文件放置路径为`/usr/share/nginx/html`

- 官方镜像默认EXPOSE 80端口

- 官方镜像模型容器启动时的CMD命令为`["nginx", "-g", "daemon off"]`，且没有设置ENTRYPOINT指令

- 官方镜像默认`nginx.conf`位于`/etc/nginx`

- 官方镜像默认`access.log`和`error.log`日志都位于`/var/log/nginx`目录下，同时做了两个软链`ln -sf /dev/stdout /var/log/nginx/access.log`和`ln -sf /dev/stderr /var/log/nginx/error.log`

# 关于本镜像Dockerfile

- 覆盖了`etc/nginx/nginx.conf`、`/etc/nginx/fastcgi.conf`

# 使用技巧和配置

nginx镜像中内置了consul-template，因此搭配consul使用可以更高的实现自动化的服务发现和配置。


# 使用（下列说明都已弃用）

## 启动时需要设置环境变量

- CONSUL_URL: 本Nginx需要配合consul使用，因此请填写consul的地址

- PHP_FASTCIG：本Nginx配置php使用时，填写php的通信地址，如127.0.0.0:9000、unix:///dev/shm/php-fpm.sock等

## 目录

- /code：放置应用代码，建议挂载卷来与php镜像共享

- /.ssh/rsa_id.pub：建议挂载宿主机的公钥来访问其他远程设备

## 部署PHP应用

php/deployInfo

key为`php/deployInfo`，其对应的值是一个json，直接设计为json格式而不继续采用consul的树状结构是因为部署信息中的giturl、domain、path、port等信息是需要同时设置并保存的，存为consul树状结构需要多次添加key/value，导致监听到多次变化。

json格式中的数据包含以下信息


```json
[
	{"gitUrl":"dqwdqwdwqd/app1","conf": [{"domain":"www.aaa.com", "path":"web", "port":"80"}]},
	{"gitUrl":"dqwdqwdwqd/app2","conf": [{"domain":"www.bbb.com", "path":"web", "port":"80"}]},
	{"gitUrl":"dqwdqwdwqd/app2","conf": [{"domain":"www.ccc.com", "path":"web", "port":"80"}]}
]
```

数组中的一个元素代表一个php部署项目代码，并且对该项目代码可以配置多个入口文件、域名、端口。

机器的consul-template自动监测kv值的变化来执行脚本进行项目部署。

## 部署自带服务的应用

内部的编排都可以通过服务别名来引用其内部地址，如在docker-compose.yml中设置了一些services，相互通信就直接link并使用服务名作为通信地址。

容器外部的访问需要通过consul对发布映射的端口进行注册，这个通过registrator自动完成注册，本nginx容器中使用consul-template来进行变化的监听并进行nginx转发调整。具体由consul-template监听到变化后执行指定脚本来配置nginx。

> 注意：注意registrator注册到consul的服务名service name，默认是使用镜像的名字，可以自己再配

自带服务的应用在配置nginx时会直接使用容器的内部ip和port，外部访问的域名需要在服务启动前进行定义，才能进行nginx配置。（涉及`deploy_custom_app.sh.tpl`脚本）

对于nginx配置的域名，目前的方案是读取配置的tag来获取应，因此tag只用作配置域名，暂时不要配置其他的

## 最佳实践

使用docker-compose。

需要服务`consul`、`registrator`即可。

通过在consul中添加相应的kv值进行项目自动部署。kv值的内容见上述`部署PHP应用`

## 一些坑

1. 容器启动命令中，正确的启动命令是`nginx -g "daemon off;"`，注意后面的参数要被引号包起来，有的情况下不包也可以运行，但有的情况下就报错运行不起来，所以正确应该是用引号包起来。其他地方也是，该用引号的用引号括起来，如/bin/bash -c "xxx"也是

2. 注意启动命令中有多个守护进程，避免前一个守护进程阻挡了后面的一个守护进程启动