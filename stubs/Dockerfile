FROM php:%PHP%-apache


# ------------------------------
# Preinstall Libarys
# ------------------------------
ADD https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/install-php-extensions /usr/local/bin/
RUN chmod uga+x /usr/local/bin/install-php-extensions && sync


# ------------------------------
# Preinstall Libarys
# ------------------------------
RUN apt-get update -y \
    && apt-get install -y \
      curl \
      git \
      libxml2-dev \
      libpng-dev \
      zlib1g-dev \
      zip unzip \
      libfreetype6-dev \
      libjpeg62-turbo-dev \
      libpng-dev \
    && apt-get clean -y


# ------------------------------
# Install Extenstions
# ------------------------------
RUN docker-php-ext-configure gd --enable-gd --with-jpeg=/usr/include/
RUN docker-php-ext-install gd
RUN install-php-extensions bz2
RUN install-php-extensions bcmath
RUN install-php-extensions calendar
RUN install-php-extensions intl
RUN install-php-extensions ldap
RUN install-php-extensions memcached
RUN install-php-extensions mysqli
RUN install-php-extensions opcache
RUN install-php-extensions pdo_mysql
RUN install-php-extensions pdo_pgsql
RUN install-php-extensions pgsql
RUN install-php-extensions redis
RUN install-php-extensions sockets
RUN install-php-extensions xsl
RUN install-php-extensions zip

RUN docker-php-ext-install exif
RUN docker-php-ext-install soap


# ------------------------------
# Restart Apache
# ------------------------------
RUN a2enmod rewrite
RUN service apache2 restart
