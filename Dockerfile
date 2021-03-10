FROM nginx:latest

VOLUME ["nginx.conf:/etc/nginx/conf.d/default.conf"]
VOLUME ["build/web:/www/data"]

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY build/web /www/data

EXPOSE 80 443

