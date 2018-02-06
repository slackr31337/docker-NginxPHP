FROM debian:stretch-slim
ENV TZ=America/New_York
RUN apt-get update
RUN apt-get install -y tzdata wget unzip vim nginx php7.0-fpm php7.0-mysql php7.0-gd php7.0-mcrypt php7.0-xsl \
php7.0-xml php7.0-xmlrpc php7.0-mbstring php7.0-zip php7.0-bcmath php7.0-curl php7.0-json php7.0-opcache \
geoip-database ca-certificates haproxy supervisor 
RUN rm -rf /var/lib/apt/lists/* /etc/nginx/sites-enabled/* 
RUN rm /etc/localtime && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV nginx_vhost /etc/nginx/sites-available/icontent.conf
ENV php_ini /etc/php/7.0/fpm/php.ini
ENV php_conf /etc/php/7.0/fpm/pool.d/www.conf
ENV nginx_conf /etc/nginx/nginx.conf
ENV haproxy_cfg /etc/haproxy/haproxy.cfg
ENV supervisor_conf /etc/supervisor/supervisord.conf

COPY php.ini ${php_ini}
COPY php.conf ${php_conf}
COPY nginx.conf ${nginx_conf}
COPY icontent.conf ${nginx_vhost}
COPY haproxy.cfg ${haproxy_cfg}
COPY supervisord.conf ${supervisor_conf}
    
RUN ln -s /etc/nginx/sites-available/icontent.conf /etc/nginx/sites-enabled/icontent.conf

RUN mkdir -p /run/php && mkdir -p /run/haproxy && \
    chown -R www-data:www-data /var/www/html && \
    chown -R www-data:www-data /run/php

RUN rm -rf /var/log/nginx/* && ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

RUN echo "alias l='ls -lah --color'" >> /root/.bashrc
RUN echo "PS1='\[\033[1;36m\]\u\[\033[1;31m\]@\[\033[1;32m\]\h:\[\033[1;35m\]\w\[\033[1;31m\]\\$\[\033[0m\] '" >> /root/.bashrc
RUN echo "PS2=\"\$HC\$FYEL&gt; \$RS\"" >> /root/.bashrc

RUN printf "set pastetoggle=<F2>\nset clipboard=unnamed\nlet b:did_indent = 1\n" > /root/.vimrc

VOLUME ["/var/www/html"]

COPY start.sh /start.sh
RUN ["chmod", "+x", "/start.sh"]
CMD ["./start.sh"]
