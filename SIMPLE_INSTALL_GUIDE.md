# 🐾 Pet Food Shop - Simple Installation Guide

## What You Have

I've created a simple pet food shop template that you can copy to any server and install with just one command!

## Files Created:

### 1. `install.sh` - Main Installation File
- **Purpose**: One-click installer that sets up everything
- **Usage**: `bash install.sh`
- **What it does**:
  - Installs Docker if needed
  - Creates all configuration files
  - Downloads and starts WordPress + WooCommerce
  - Sets up sample pet products
  - Ready to use in 5 minutes

### 2. `create-web-template.sh` - Template Generator
- **Purpose**: Creates a clean template package
- **Usage**: `bash create-web-template.sh`
- **What it creates**:
  - Complete folder with all files needed
  - Can be copied to any server
  - Self-contained installation

## Quick Start Steps:

### For Current Server:
```bash
# Run the installer
bash install.sh

# Visit your shop
# http://localhost:8000
```

### For New Server:
```bash
# 1. Create template package
bash create-web-template.sh

# 2. Copy the 'pet-food-shop-template' folder to new server

# 3. On new server, run:
cd pet-food-shop-template
bash install.sh
```

## What You Get:

✅ **Complete Pet Food Shop**
- WordPress + WooCommerce
- Sample pet products (Dog food, Cat food, Toys, Beds, Shampoo)
- Professional storefront theme
- Shopping cart and checkout
- Payment processing ready

✅ **Management Tools**
- Database admin (phpMyAdmin) at http://localhost:8080
- Email testing (MailHog) at http://localhost:8025
- WordPress admin at http://localhost:8000/wp-admin

✅ **Easy Migration**
- Copy folder to any server
- Run one install command
- Everything works immediately

## Access Information:

- **Shop**: http://localhost:8000
- **Admin Panel**: http://localhost:8000/wp-admin
- **Database**: http://localhost:8080 (user: root, password: petshop456)
- **Email Testing**: http://localhost:8025

## Commands:

```bash
# Start shop
docker-compose up -d

# Stop shop  
docker-compose down

# View logs
docker-compose logs -f

# Restart
docker-compose restart
```

## Perfect For:

- Pet stores
- Animal food shops
- Pet supply businesses
- Veterinary clinics
- Pet grooming services

## Features:

- Mobile-responsive design
- Product catalog
- Shopping cart
- Customer accounts
- Order management
- Payment integration ready
- Inventory management
- SEO optimized

Your shop is now ready to customize with your own products, branding, and payment methods!