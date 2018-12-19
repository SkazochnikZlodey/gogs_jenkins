
upstream upstream_backend {
    server  tplphp:9000;
#    server  bbaphp2:9000; # max_fails=3 fail_timeout=30s
}


server {
    listen 80;
    listen [::]:80;

    index index.html;

     error_log /var/log/nginx/error.log;
     access_log /var/log/access.log;

    location ~ \.(jpg|jpeg|gif|png|img|ico|svg|csv|pdf|css|js|ttf|otf|woff|woff2|svg)$ {
        root /source/wwwroot;
        try_files $uri =404;

        access_log off;
    }

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        root            /source/wwwroot;
        fastcgi_pass    upstream_backend;
        fastcgi_index   index.php;
        fastcgi_param   SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include         fastcgi_params;
    }
}
