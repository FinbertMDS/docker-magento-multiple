FROM ubuntu:16.04

RUN apt-get update \
    && apt-get install -y supervisor \
    && mkdir -p /var/log/supervisor \
    ##install varnish
    && apt-get -y install varnish

RUN rm /etc/varnish/default.vcl
RUN rm /etc/default/varnish

COPY varnish /etc/default/varnish
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 6082 80
CMD ["/usr/bin/supervisord"]