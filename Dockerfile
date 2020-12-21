FROM debian:buster

MAINTAINER Mehdi Naji <mnaji@student.42.fr>

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get -y install nginx \
    && apt-get -y install mariadb-server\
    && apt-get -y install php7.3 php-mysql php-fpm php-cli php-mbstring \
    && apt-get -y install wget

COPY ./srcs/start.sh /var/
COPY ./srcs/mysql_setup.sql /var/
COPY ./srcs/wordpress.sql /var/
COPY ./srcs/wordpress.tar.gz /var/www/html/
COPY ./srcs/nginx.conf /etc/nginx/sites-available/localhost
RUN ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/localhost

WORKDIR /var/www/html/
RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.9.1/phpMyAdmin-4.9.1-english.tar.gz \
    && tar xf phpMyAdmin-4.9.1-english.tar.gz && rm -rf phpMyAdmin-4.9.1-english.tar.gz \
    && mv phpMyAdmin-4.9.1-english phpmyadmin
COPY ./srcs/config.inc.php phpmyadmin

RUN tar xf ./wordpress.tar.gz && rm -rf wordpress.tar.gz \
    && chmod 755 -R wordpress

RUN service mysql start && mysql -u root mysql < /var/mysql_setup.sql && mysql wordpress -u root --password= < /var/wordpress.sql \
    && openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj '/C=FR/ST=75/L=Paris/O=42/CN=mnaji' -keyout /etc/ssl/certs/localhost.key -out /etc/ssl/certs/localhost.crt \
    && chown -R www-data:www-data * \
    && chmod 755 -R *

CMD bash /var/start.sh

EXPOSE 80 443

#docker run -p 443:443 <image_id>