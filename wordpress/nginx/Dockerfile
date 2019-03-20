FROM nginx:1.13-alpine

RUN apk update && \
    apk add curl

COPY ./nginx.conf /etc/nginx/conf.d/default.conf
COPY ./index.html /usr/share/nginx/html/index.html