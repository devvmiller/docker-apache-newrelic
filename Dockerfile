FROM php:7.2.4-apache

ENV TERM xterm-256color
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
      git \
      locales \
      libmcrypt-dev \
      zip \
      unzip \
      cron \
  && a2enmod rewrite \
  && apt-get autoremove -y && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# database
RUN docker-php-ext-install \
  mysqli \
  pdo \
  pdo_mysql

# strings
RUN docker-php-ext-install \
  gettext \
  mbstring

# PECL
RUN pecl install -o -f redis \
&&  rm -rf /tmp/pear \
&&  docker-php-ext-enable redis

RUN dpkg-reconfigure locales \
  && locale-gen C.UTF-8 \
  && /usr/sbin/update-locale LANG=C.UTF-8

RUN echo 'fr_CA.UTF-8 UTF-8' >> /etc/locale.gen \
  && locale-gen

ENV NR_INSTALL_SILENT 1
RUN newrelic-install install \
    && sed -i \
        -e "s/newrelic.license =.*/newrelic.license = \${NEW_RELIC_LICENSE_KEY}/" \
        -e "s/newrelic.appname =.*/newrelic.appname = \${NEW_RELIC_APP_NAME}/" \
        /usr/local/etc/php/conf.d/newrelic.ini

ENV LANG fr_CA.UTF-8
ENV LANGUAGE fr_CA:en
ENV LC_ALL fr_CA.UTF-8

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN rm -Rf /var/www/html

WORKDIR /var/www
