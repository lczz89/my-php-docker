#!/bin/bash

set -e

# 声明关联数组nginxInfo
# declare -A nginxInfo
# 声明索引数组
deployInfo=()
nginxInfo=()
reloadNginx="0"

codeDir="/code"

{{ with $projects := key "php/deployInfo" | parseJSON}}
{{ range $project := $projects}}
fileName=`basename {{$project.gitUrl}} .git`
deployInfo=(${deployInfo[@]} "{{$project.gitUrl}}|$fileName")
{{ range $conf := $project.conf }}
nginxInfo=(${nginxInfo} "$fileName|{{ $conf.domain }}|{{ $conf.path }}|{{ $conf.port }}")
{{ end }}

{{ end }}
{{ end }}


# 遍历部署
for element in ${deployInfo[@]}
do
	dir=$(echo $element | cut -d"|" -f2)
	giturl=$(echo $element | cut -d"|" -f1)
#	if [ ! -d "$codeDir/$dir" ];then
#		git clone $giturl $codeDir/$dir
#	fi
done


# 遍历删除
for existdir in $(ls /$codeDir)
do
	for element in ${deployInfo[@]}
	do
		dir=$(echo $element | cut -d"|" -f2)
		if [ "$existdir" == "$dir" ];then
			continue 2
		fi
	done
	rm -rf $codeDir/$existdir
done

rm -f /etc/nginx/conf.d/php_app_*.conf

# 遍历配置nginx
for conf in ${nginxInfo[@]}
do
	domain="$(echo $conf | cut -d"|" -f2)"
	path="$(echo $conf | cut -d"|" -f3)"
	port="$(echo $conf | cut -d"|" -f4)"
	root="$codeDir/$(echo $conf | cut -d"|" -f1)/$path"
	# 注意这里sed替换的替换字符里有斜杠/时，定界符就不要用斜杠了，会有问题，可以用#
	sed -e "s#NGINX_SERVER_NAME#${domain}#" -e "s#NGINX_PORT#${port}#" -e "s#NGINX_DOCUMENT_ROOT#${root}#" /etc/nginx/nginx_php_app_conf.tpl | tee /etc/nginx/conf.d/php_app_${domain}.conf
	reloadNginx="1"
done


if [[ $reloadNginx == "1" ]];then
	nginx -s reload
fi