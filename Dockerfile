FROM php:8.2-fpm-alpine

# Install system dependencies
RUN apk add --no-cache \
    postgresql \
    postgresql-dev \
    postgresql-contrib \
    nginx \
    supervisor \
    git \
    zip \
    unzip \
    libzip-dev \
    icu-dev \
    bash \
    curl

# Install Symfony CLI
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.alpine.sh' | bash && \
    apk add symfony-cli

# Install PHP extensions
RUN docker-php-ext-install \
    pdo \
    pdo_pgsql \
    zip \
    intl

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configure PostgreSQL
RUN mkdir -p /run/postgresql && \
    chown postgres:postgres /run/postgresql && \
    mkdir -p /var/lib/postgresql/data && \
    chown postgres:postgres /var/lib/postgresql/data && \
    su postgres -c 'initdb -D /var/lib/postgresql/data' && \
    echo "host all all all md5" >> /var/lib/postgresql/data/pg_hba.conf

# Configure PHP-FPM
COPY docker/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf

# Configure Nginx
COPY docker/nginx.conf /etc/nginx/nginx.conf

# Configure Supervisor
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Set working directory
WORKDIR /var/www

# Start services
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]