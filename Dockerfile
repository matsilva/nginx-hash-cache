FROM nginx:1.13-alpine

RUN apk add --no-cache bash curl

COPY nginx/ /

CMD ["/docker-entrypoint.sh", "nginx", "-g", "daemon off;"]

EXPOSE 8080

COPY build/static/ /usr/share/nginx/html/

COPY package.json /
