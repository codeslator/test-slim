# Install the base image
FROM php:8.3-apache

# Install the required system dependencies
RUN apt-get update && apt-get install -y \
  libzip-dev \
  zip \
  unzip \
  libpng-dev \
  libjpeg-dev \
  libfreetype6-dev \
  libonig-dev \
  libxml2-dev \
  && rm -rf /var/lib/apt/lists/*

# Install the required PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install -j$(nproc) \
  gd \
  pdo_mysql \
  mbstring \
  zip \
  xml \
  fileinfo \
  mbstring \
  xml \
  opcache

# Install composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Enable Apache modules
RUN a2enmod rewrite

# Setup root directory for Apache
ENV APACHE_DOCUMENT_ROOT=/var/www/html

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

WORKDIR ${APACHE_DOCUMENT_ROOT}

# Copy the application files to the container
COPY . .

RUN composer install
# Puerto expuesto
EXPOSE 80

CMD ["/bin/sh", "-c", "apache2-foreground", "php -S localhost:8080 -t public"]