# Sets up PHP7, composer, NodeJS and Cron

FROM php:7.2.8-fpm

#Set up image foundation
RUN apt-get update 
RUN apt-get install -y wget
RUN apt-get install -y gnupg
RUN apt-get install -y git
RUN apt-get install -y unzip
RUN apt-get install -y zip
RUN apt-get install -y cron

#Install PHP extentions & dependencies
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install sysvsem

RUN apt-get install -y \
        libzip-dev \
        zip \
  && docker-php-ext-configure zip --with-libzip \
  && docker-php-ext-install zip

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

WORKDIR /var/www

#Install and move composer to global path
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer
ENV PATH $PATH:~/.composer/vendor/bin

#Install nodeJS
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash
RUN apt-get install -y nodejs
RUN apt-get install -y build-essential

#RUN crontab -l | { cat; echo "* * * * * /usr/local/bin/php /var/www/html/index.php phpScriptToExecute.php"; } | crontab - \
#&& crontab -l | { cat; echo "* * * * * /usr/local/bin/php /var/www/html/index.php phpScriptToExecute.php"; } | crontab - \

# Using dev php.ini copy, do this at the bottom of every small ini change will need a complete rebuild
# php.ini editing reference http://php.net/manual/en/ini.list.php
COPY ./build-files/php7fpm/php.ini /usr/local/etc/php/php.ini
COPY ./build-files/php7fpm/php-docker-entrypoint.sh /
RUN chmod 700 /php-docker-entrypoint.sh

ENTRYPOINT ["/php-docker-entrypoint.sh"]