location ~ \.php$ {
    try_files $uri =404;

    include fastcgi_params;

    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_param  PATH_INFO          $fastcgi_path_info;
    #fastcgi_param  PATH_TRANSLATED    $document_root$fastcgi_path_info;
    fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;

    fastcgi_pass   ${PHP_FASTCIG};
    #fastcgi_pass   127.0.0.1:9000;
    # fastcgi_pass php:9000;
    fastcgi_index  index.php;
}