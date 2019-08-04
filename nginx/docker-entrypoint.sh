#!/usr/bin/env bash

mkdir -p /etc/nginx/conf.d/app
pushd /usr/share/nginx/html/js/ > /dev/null

APP_JS=/app/js/app.js
for js in main.*.*.js
do
    cat  > /etc/nginx/conf.d/app/js.conf <<EOF
location ~* ^/app/js/main.js([.]map)?\$ {
    expires off;
    add_header Cache-Control "no-cache";
    return 303 ${js}\$1;
}
location ~* ^/app/js/(main[.][a-z0-9][a-z0-9]*[.]js(?:[.]map)?)\$ {
    alias   /usr/share/nginx/html/js/\$1;
    expires max;
    add_header Cache-Control "public; immutable";
}
EOF
    APP_JS="/js/${js}"
    break;
done
RUNTIME_JS=/app/js/runtime.js
for js in runtime~main.*.js
do
    cat  > /etc/nginx/conf.d/app/js.conf <<EOF
location ~* ^/app/js/runtime~main.js([.]map)?\$ {
    expires off;
    add_header Cache-Control "no-cache";
    return 303 ${js}\$1;
}
location ~* ^/app/js/(runtime~main[.][a-z0-9][a-z0-9]*[.]js(?:[.]map)?)\$ {
    alias   /usr/share/nginx/html/js/\$1;
    expires max;
    add_header Cache-Control "public; immutable";
}
EOF
    RUNTIME_JS="/js/${js}"
    break;
done
VENDOR_JS=/app/js/vendor.js
for js in 2.*.*.js
do
    cat >> /etc/nginx/conf.d/app/js.conf <<EOF
location ~* ^/app/js/2[.]js([.]map)?\$ {
    expires off;
    add_header Cache-Control "no-cache";
    return 303 ${js}\$1;
}
location ~* ^/app/js/(2[.][a-z0-9][a-z0-9]*[.]js(?:[.]map)?)\$ {
    alias   /usr/share/nginx/html/js/\$1;
    expires max;
    add_header Cache-Control "public; immutable";
}
EOF
    VENDOR_JS="/js/${js}"
    break;
done

cd ../css
APP_CSS=/app/css/main.css
for css in main.*.*.css
do
    cat > /etc/nginx/conf.d/app/css.conf <<EOF
location ~* ^/app/css/main.css([.]map)?\$ {
    expires off;
    add_header Cache-Control "no-cache";
    return 303 ${css}\$1;
}
location ~* ^/app/css/(main[.][a-z0-9][a-z0-9]*[.]css(?:[.]map)?)\$ {
    alias   /usr/share/nginx/html/css/\$1;
    expires max;
    add_header Cache-Control "public; immutable";
}
EOF
    APP_CSS="/css/${css}"
done

cd ..

cat > /etc/nginx/conf.d/app/preload.headers <<EOF
add_header Cache-Control "public; must-revalidate";
add_header Link "<${APP_CSS}>; rel=preload; as=style; type=text/css; nopush";
add_header Link "<${VENDOR_JS}>; rel=preload; as=script; type=text/javascript; nopush";
add_header Link "<${APP_JS}>; rel=preload; as=script; type=text/javascript; nopush";
add_header X-Frame-Options "SAMEORIGIN" always;
EOF

cat > index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <meta http-equiv="X-UA-Compatible" content="ie=edge"/>
    <title>Create React app</title>
    <link href="${APP_CSS}" rel="stylesheet">
</head>
<body>
    <div id="root"></div>
    <script type="text/javascript" src="${VENDOR_JS}"></script>
    <script type="text/javascript" src="${APP_JS}"></script>
    <script type="text/javascript" src="${RUNTIME_JS}"></script>
</body>
</html>
EOF

popd > /dev/null

exec "$@"