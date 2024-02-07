FROM nginx:latest

VOLUME ["nginx.conf:/etc/nginx/conf.d/default.conf"]
VOLUME ["build/web:/www/data/app"]

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY build/web /www/data/app

EXPOSE 80 443

