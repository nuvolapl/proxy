FROM alpine:latest

RUN apk update && apk upgrade

RUN apk add --update \
    curl

RUN curl --silent --show-error --fail --location --header \
    "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" -o - \
    "https://caddyserver.com/download/linux/amd64?&license=personal&telemetry=off" | tar --no-same-owner -C /usr/bin/ -xz caddy

RUN addgroup -g 2432 -S nuvola
RUN adduser -D -S -H -s /sbin/nologin -G nuvola caddy

COPY ./proxy/.docker/services/proxy/Caddyfile /etc/Caddyfile
COPY ./*/.docker/services/proxy/conf.d/*.conf /etc/conf.d/
COPY ./*/public/* /var/www/public/

USER caddy

EXPOSE 8888

ENTRYPOINT ["/usr/bin/caddy"]

CMD ["--conf", "/etc/Caddyfile"]
