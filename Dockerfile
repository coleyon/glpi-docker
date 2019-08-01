FROM php:7.3-apache-stretch as production

ARG DEBIAN_FRONTEND=${DEBIAN_FRONTEND:-noninteractive}
ARG DEBCONF_NOWARNINGS=${DEBCONF_NOWARNINGS:-"yes"}
ARG TIMEZONE=${TIMEZONE:-Asia/Tokyo}
ARG TIME_ZONE=${TIMEZONE}
ARG VERSION_GLPI=${VERSION_GLPI:-9.4.3}

WORKDIR /var/www/html

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install \
    apt-utils \
    mysql-client \
    curl \
    cron \
    wget \
    jq \
    tzdata \
    locales \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libxml2-dev \
    libc-client-dev \
    libkrb5-dev \
    libldap2-dev \
    fonts-ipafont \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

RUN locale-gen ja_JP.UTF-8 \
    && localedef -f UTF-8 -i ja_JP ja_JP.utf8 \
    && ln -snf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime && echo $TIME_ZONE > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata \
    && dpkg-reconfigure -f noninteractive locales \
    && a2enmod rewrite

# https://glpi-install.readthedocs.io/en/latest/prerequisites.html#mandatory-extensions
# https://glpi-install.readthedocs.io/en/latest/prerequisites.html#optional-extensions
RUN docker-php-ext-install mysqli \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && docker-php-ext-install simplexml \
    && docker-php-ext-install xml \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap \
    && docker-php-ext-install ldap \
    && docker-php-ext-install xmlrpc \
    && docker-php-ext-install opcache \
    && printf "\n" | pecl install apcu

COPY ["containers/php/conf.d/glpiconf.ini", "containers/php/conf.d/timezone.ini", "containers/php/conf.d/apcu.ini", "/usr/local/etc/php/conf.d/"]
COPY ["containers/glpi_cron", "/etc/cron.d/"]
COPY ["containers/apache2/000-default.conf", "/etc/apache2/sites-available/"]
COPY ["containers/ldap.conf", "/etc/ldap/"]
COPY ["containers/put_glpi.sh", "/opt/"]
# COPY ["patches/", "/tmp/patches/"]

# Downloading plain glpi and settings
RUN chmod +x /opt/put_glpi.sh \
    && /opt/put_glpi.sh

EXPOSE 80
EXPOSE 443
