# FROM php:$PHP_VERSION-fpm

# RUN apt-get update && apt-get install -y  \
#     libmagickwand-dev \
#     --no-install-recommends \
#     && pecl install imagick \
#     && docker-php-ext-enable imagick \
#     && docker-php-ext-install pdo_mysql

# PHP Version environment variable
ARG PHP_VERSION

# PHP Version alpine image to install based on the PHP_VERSION environment variable
FROM php:$PHP_VERSION-fpm-alpine

# Application environment variable
ARG APP_ENV

# Remote working directory environment variable
ARG REMOTE_WORKING_DIR

# Install Additional dependencies
RUN apk update && apk add --no-cache $PHPIZE_DEPS \
   build-base shadow nano curl gcc git bash \
   php8 \
   php8-fpm \
   php8-common \
   php8-pdo \
   php8-pdo_mysql \
   php8-mysqli \
   php8-pecl-mcrypt \
   php8-mbstring \
   php8-xml \
   php8-openssl \
   php8-phar \
   php8-zip \
   php8-gd \
   php8-dom \
   php8-session \
   php8-zlib
#   php8-json \

# Install extensions
RUN docker-php-ext-install pdo pdo_mysql
RUN docker-php-ext-enable pdo_mysql

# install xdebug and enable it if the development environment is local
RUN if [ $APP_ENV = "local" ]; then \
   pecl install xdebug; \
   docker-php-ext-enable xdebug; \
fi;

# Install PHP Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Remove Cache
RUN rm -rf /var/cache/apk/*

# Add UID '1000' to www-data
RUN apk add shadow && usermod -u 1000 www-data && groupmod -g 1000 www-data

# Copy existing application directory permissions
COPY --chown=www-data:www-data . $REMOTE_WORKING_DIR

# Change current user to www
USER www-data

# Expose port 9000 and start php-fpm server
EXPOSE 9000

# Run php-fpm
CMD ["php-fpm"]