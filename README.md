# WordPress + WooCommerce Development Environment

A complete WordPress and WooCommerce e-commerce development environment using Docker Compose.

## Services

- **WordPress**: Latest WordPress version running on port 8000
- **WooCommerce**: Complete e-commerce solution
- **MySQL 8.0**: Database server
- **phpMyAdmin**: Database management interface on port 8080
- **Redis**: Caching server on port 6379
- **MailHog**: Email testing interface on port 8025

## Quick Start

1. **Start the environment:**
   ```bash
   docker-compose up -d
   ```

2. **Complete WordPress installation:**
   - URL: http://localhost:8000
   - Follow the WordPress installation wizard

3. **Setup WooCommerce (after WordPress installation):**
   ```bash
   ./setup-woocommerce.sh
   ```

4. **Access your services:**
   - **WordPress/WooCommerce**: http://localhost:8000
   - **phpMyAdmin**: http://localhost:8080
   - **Email Testing**: http://localhost:8025

## Development Features

- **WooCommerce**: Complete e-commerce platform
- **Volume mounting**: Your `wp-content` folder is mounted to the container
- **Debug mode**: WordPress debug is enabled for development
- **Persistent data**: Database and WordPress files persist between container restarts
- **Email testing**: MailHog for testing order emails and notifications
- **Caching**: Redis for improved performance
- **Optimized PHP**: Increased memory and upload limits for WooCommerce

## WooCommerce Features Included

✅ **Complete e-commerce solution**  
✅ **Product management**  
✅ **Order processing**  
✅ **Payment gateways**  
✅ **Shipping methods**  
✅ **Tax calculations**  
✅ **Customer accounts**  
✅ **Inventory management**  
✅ **Analytics and reporting**  
✅ **Sample data** for testing  

## Useful Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Rebuild containers
docker-compose up -d --build

# Remove everything (including volumes)
docker-compose down -v

# Setup WooCommerce (after WordPress installation)
./setup-woocommerce.sh

# Access WordPress CLI
docker exec -it wordpress_app wp --allow-root
```

## Database Credentials

- **Database Host**: `db`
- **Database Name**: `wordpress`
- **Database User**: `wordpress`
- **Database Password**: `wordpress_password`
- **Root Password**: `rootpassword`

## File Structure

```
.
├── docker-compose.yml
├── setup-woocommerce.sh
├── uploads.ini
├── wp-content/          # Your themes, plugins, uploads
└── README.md
```

## WooCommerce Setup Process

1. **Start containers**: `docker-compose up -d`
2. **Install WordPress**: Complete setup at http://localhost:8000
3. **Run setup script**: `./setup-woocommerce.sh`
4. **Configure store**: Access WooCommerce settings in WordPress admin
5. **Add products**: Start building your product catalog

## Customization

- Modify `docker-compose.yml` to change ports, passwords, or add additional services
- Add your custom themes and plugins to the `wp-content` directory
- Configure WooCommerce settings in WordPress admin
- Customize the `setup-woocommerce.sh` script for your specific needs

## Payment Testing

For development, you can use these test payment methods:
- **Stripe**: Use test card numbers (4242 4242 4242 4242)
- **PayPal**: Use sandbox accounts
- **Cash on Delivery**: Available by default

## Performance Optimization

- Redis caching is enabled for better performance
- PHP memory limits increased for WooCommerce
- Upload limits optimized for product images
- Debug logging enabled for development 