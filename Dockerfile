# Pet Food E-commerce Platform - Custom WordPress Docker Image
FROM wordpress:6.4-php8.1-apache

# Set maintainer
LABEL maintainer="Pet Food E-commerce Platform"
LABEL description="WordPress/WooCommerce platform for pet food stores"
LABEL version="1.0.0"

# Install additional PHP extensions and system packages
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    unzip \
    curl \
    wget \
    vim \
    nano \
    mariadb-client \
    && docker-php-ext-install zip \
    && docker-php-ext-enable zip \
    && rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/wp-cli/v2.8.1/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp \
    && wp --info --allow-root

# Install additional tools for theme management
RUN apt-get update && apt-get install -y \
    git \
    rsync \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Set proper PHP configuration for WooCommerce
RUN { \
    echo 'memory_limit = 512M'; \
    echo 'upload_max_filesize = 64M'; \
    echo 'post_max_size = 64M'; \
    echo 'max_execution_time = 300'; \
    echo 'max_input_vars = 3000'; \
    echo 'session.gc_maxlifetime = 1440'; \
    echo 'opcache.enable = 1'; \
    echo 'opcache.memory_consumption = 128'; \
    echo 'opcache.max_accelerated_files = 4000'; \
    echo 'opcache.revalidate_freq = 60'; \
} > /usr/local/etc/php/conf.d/woocommerce.ini

# Copy custom wp-content (themes, plugins, uploads)
COPY pet-food-shop-template/wp-content/ /var/www/html/wp-content/

# Copy WooCommerce configuration
COPY woocommerce-config.php /var/www/html/wp-content/mu-plugins/woocommerce-config.php

# Copy Theme Manager
COPY theme-manager.php /var/www/html/wp-content/mu-plugins/theme-manager.php
COPY theme-manager.js /var/www/html/wp-content/themes/assets/theme-manager.js

# Copy upload configuration
COPY uploads.ini /usr/local/etc/php/conf.d/uploads.ini

# Create necessary directories and set permissions
RUN mkdir -p /var/www/html/wp-content/mu-plugins \
    && mkdir -p /var/www/html/wp-content/uploads \
    && mkdir -p /var/www/html/wp-content/logs \
    && mkdir -p /var/www/html/wp-content/themes-backup \
    && mkdir -p /usr/local/bin/theme-manager \
    && chown -R www-data:www-data /var/www/html/wp-content \
    && chmod -R 755 /var/www/html/wp-content

# Copy custom Apache configuration if needed
COPY apache-config.conf /etc/apache2/conf-available/wordpress.conf
RUN a2enconf wordpress

# Enable Apache modules
RUN a2enmod rewrite headers expires deflate

# Create custom entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Set working directory
WORKDIR /var/www/html

# Expose port
EXPOSE 80

# Use custom entrypoint
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]