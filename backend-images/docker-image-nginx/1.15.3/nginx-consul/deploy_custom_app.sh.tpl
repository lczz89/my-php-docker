#!/bin/bash

reloadNginx="0"
services=()

{{ range services }}
{{ range service .Name }}
# http://127.0.0.1:80|aaa,ccc,www.dsad.das
# 这里的协议后期可能需要自动化
services=(${services[@]} 'http://{{ .Address }}:{{.Port}}|{{ .Tags | join ","}}')
{{ end }}
{{ end }}

# shell中数组的分隔符$IFS
OLD_IFS="$IFS"
IFS=","

# 匹配域名的正则表达式
regex="([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6}"

rm -f /etc/nginx/conf.d/custom_app_*.conf

for service in ${services[@]}
do
	passAddress=$(echo $service | cut -d "|" -f1)
	tags=$(echo $service | cut -d "|" -f2)
	for tag in ${tags[@]}
	do
		if [[ $tag =~ $regex ]];then
			domain="$tag"
			sed -e "s#NGINX_SERVER_NAME#${domain}#" -e "s#NGINX_PASS_ADDRESS#${passAddress}#" /etc/nginx/nginx_custom_app_conf.tpl | tee /etc/nginx/conf.d/custom_app_${domain}.conf
			reloadNginx="1"
			break
		fi
	done
done


# 恢复分隔符
IFS="$OLD_IFS"

if [[ $reloadNginx == "1" ]];then
	nginx -s reload
fi
