# WordPress Docker Compose Setup

## Quick Start

1. Create environment file (optional):
   ```bash
   cat > .env << EOF
   WORDPRESS_DB_PASSWORD=secure_wordpress_password
   MYSQL_ROOT_PASSWORD=secure_root_password
   EOF
   ```

2. Start WordPress:
   ```bash
   docker-compose up -d
   ```

3. Access WordPress:
   - WordPress site: http://localhost:8080
   - phpMyAdmin: http://localhost:8081

4. Complete WordPress installation:
   - Choose language
   - Enter site information
   - Create admin user

## Services

- **wordpress**: WordPress CMS
- **wordpress-db**: MySQL 8.0 database
- **phpmyadmin**: Database management interface

## Ports

- 8080: WordPress website
- 8081: phpMyAdmin interface

## Environment Variables

You can customize these in a `.env` file:
- `WORDPRESS_DB_PASSWORD`: WordPress database password (default: wordpress_password)
- `MYSQL_ROOT_PASSWORD`: MySQL root password (default: root_password)

## Volumes

- `wordpress-data`: WordPress files and uploads
- `wordpress-db-data`: MySQL database files

## Database Access

- **Database**: wordpress
- **Username**: wordpress
- **Password**: Set via WORDPRESS_DB_PASSWORD
- **Root Password**: Set via MYSQL_ROOT_PASSWORD

## Backup

To backup your WordPress:
```bash
# Backup database
docker exec wordpress-db mysqldump -u root -p[ROOT_PASSWORD] wordpress > backup.sql

# Backup files
docker cp wordpress:/var/www/html ./wordpress-backup
```

## Security Notes

- Change default passwords in production
- Use strong passwords
- Consider using WordPress security plugins
- Keep WordPress and plugins updated
