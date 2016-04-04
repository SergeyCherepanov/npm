location ~ ^/nginx_(status|ping) {
    stub_status on;
    access_log   off;
    # allow 192.168.100.1; 
    allow 127.0.0.1;
    deny all;
}

location ~ ^/fpm_(status|ping)$ {
    access_log off;
    # allow 192.168.100.1;
    allow 127.0.0.1;
    deny all;
    include                         fastcgi_params;
    fastcgi_param SCRIPT_FILENAME   $document_root$fastcgi_script_name;
    fastcgi_pass                    unix:/var/run/php5-fpm.sock;
}

