FROM php:%PHP%-apache

# ------------------------------
# Preinstall Libarys
# ------------------------------
RUN apt-get update -y \
  && apt-get install -y \
      curl \
      zip unzip \
      libxml2-dev \
  && apt-get clean -y \

# ------------------------------
# Install Extenstions
# ------------------------------
RUN docker-php-ext-install bcmath \
    bz2 \
    calendar \
    exif \
    gd \
    intl \
    memcached \
    mysqli \
    opcache \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    redis \
    soap \
    sockets \
    zip

# ------------------------------
# Restart Apache
# ------------------------------
RUN a2enmod rewrite
RUN service apache2 restart
