# WordPress Docker Swarm Setup# WordPress Docker Swarm Setup

## Description## Description

Complete WordPress setup with MySQL database, Redis cache, and optional phpMyAdmin for Docker Swarm environments.Complete WordPress setup with MySQL database, Redis cache, and optional phpMyAdmin for Docker Swarm environments.

## Features## Features

- **WordPress**: Latest version with optimized configuration- **WordPress**: Latest version with optimized configuration

- **MySQL 8.0**: High-performance database with custom optimizations- **MySQL 8.0**: High-performance database with custom optimizations

- **Redis**: Caching layer for improved performance- **Redis**: Caching layer for improved performance

- **phpMyAdmin**: Database management interface (optional)- **phpMyAdmin**: Database management interface (optional)

- **NFS Storage**: Persistent data on network storage- **NFS Storage**: Persistent data on network storage

- **Health Checks**: Comprehensive health monitoring- **Health Checks**: Comprehensive health monitoring

- **Secrets Management**: Secure password handling- **Secrets Management**: Secure password handling

- **High Availability**: Multi-replica support- **High Availability**: Multi-replica support

## Prerequisites## Prerequisites

- Docker Swarm cluster- Docker Swarm cluster

- NFS server configured (truenas-scale)- NFS server configured (truenas-scale)

- Cloudflare proxy network (optional)- Cloudflare proxy network (optional)

## Secrets Configuration## Secrets Configuration

Create the following secret files:Create the following secret files:

`bash`bash

# Database password# Database password

echo "your_secure_db_password" > wordpress_db_password.txtecho "your_secure_db_password" > wordpress_db_password.txt

# MySQL root password # MySQL root password

echo "your_secure_root_password" > mysql_root_password.txtecho "your_secure_root_password" > mysql_root_password.txt

# Domain configuration# Domain configuration

echo "wordpress.yourdomain.com" > wordpress_domain.txtecho "wordpress.yourdomain.com" > wordpress_domain.txt

````



## Storage Paths## Storage Paths



Ensure these NFS paths exist on your TrueNAS:Ensure these NFS paths exist on your TrueNAS:

- `/mnt/slowbro/docker/wordpress/db` - MySQL data- `/mnt/slowbro/docker/wordpress/db` - MySQL data

- `/mnt/slowbro/docker/wordpress/app` - WordPress files- `/mnt/slowbro/docker/wordpress/app` - WordPress files

- `/mnt/slowbro/docker/wordpress/redis` - Redis cache data- `/mnt/slowbro/docker/wordpress/redis` - Redis cache data



## Deployment## Deployment



```bash```bash

# Deploy the stack# Deploy the stack

docker stack deploy -c docker-compose.yml wordpressdocker stack deploy -c docker-compose.yml wordpress



# Check status# Check status

docker service ls | grep wordpressdocker service ls | grep wordpress



# View logs# View logs

docker service logs wordpress_wordpressdocker service logs wordpress_wordpress

docker service logs wordpress_wordpress-dbdocker service logs wordpress_wordpress-db

````

## Access## Access

- **WordPress**: Access through Cloudflare proxy or configured domain- **WordPress**: Access through Cloudflare proxy or configured domain

- **phpMyAdmin**: Enable service and access through proxy (commented by default)- **phpMyAdmin**: Enable service and access through proxy (commented by default)

## Configuration## Configuration

### WordPress Optimizations### WordPress Optimizations

- Redis object caching enabled- Redis object caching enabled

- File editing disabled in admin- File editing disabled in admin

- Auto-updates disabled- Auto-updates disabled

- Memory limit: 256M- Memory limit: 256M

- SSL admin enforcement- SSL admin enforcement

### MySQL Optimizations### MySQL Optimizations

- InnoDB buffer pool: 256M- InnoDB buffer pool: 256M

- Query cache enabled- Query cache enabled

- Slow query logging- Slow query logging

- Optimized authentication- Optimized authentication

### Redis Configuration### Redis Configuration

- Append-only persistence- Append-only persistence

- LRU eviction policy- LRU eviction policy

- 128MB memory limit- 128MB memory limit

## Management## Management

`bash`bash

# Scale WordPress instances# Scale WordPress instances

docker service scale wordpress_wordpress=3docker service scale wordpress_wordpress=3

# Update WordPress# Update WordPress

docker service update --image wordpress:latest wordpress_wordpressdocker service update --image wordpress:latest wordpress_wordpress

# Backup database# Backup database

docker exec $(docker ps -q -f name=wordpress_wordpress-db) \docker exec $(docker ps -q -f name=wordpress_wordpress-db) \

mysqldump -u root -p wordpress > backup.sql mysqldump -u root -p wordpress > backup.sql

# Restore database# Restore database

docker exec -i $(docker ps -q -f name=wordpress_wordpress-db) \docker exec -i $(docker ps -q -f name=wordpress_wordpress-db) \

mysql -u root -p wordpress < backup.sql mysql -u root -p wordpress < backup.sql

````



## Monitoring## Monitoring



All services include health checks:All services include health checks:

- **WordPress**: HTTP endpoint monitoring- **WordPress**: HTTP endpoint monitoring

- **MySQL**: Database connectivity- **MySQL**: Database connectivity

- **Redis**: Ping response- **Redis**: Ping response



## Security Features## Security Features



- Secrets for sensitive data- Secrets for sensitive data

- Encrypted overlay networks- Encrypted overlay networks

- Non-root containers where possible- Non-root containers where possible

- File edit restrictions- File edit restrictions

- SSL enforcement- SSL enforcement



## Troubleshooting## Troubleshooting



```bash```bash

# Check service status# Check service status

docker service ps wordpress_wordpress --no-truncdocker service ps wordpress_wordpress --no-trunc



# View service logs# View service logs

docker service logs -f wordpress_wordpressdocker service logs -f wordpress_wordpress



# Debug network connectivity# Debug network connectivity

docker exec -it $(docker ps -q -f name=wordpress_wordpress) ping wordpress-dbdocker exec -it $(docker ps -q -f name=wordpress_wordpress) ping wordpress-db



# Check NFS mounts# Check NFS mounts

docker exec -it $(docker ps -q -f name=wordpress_wordpress) df -hdocker exec -it $(docker ps -q -f name=wordpress_wordpress) df -h

````

## Performance Tuning## Performance Tuning

### For high traffic:### For high traffic:

1. Increase WordPress replicas: `replicas: 4`1. Increase WordPress replicas: `replicas: 4`

2. Adjust MySQL resources based on usage2. Adjust MySQL resources based on usage

3. Enable Redis persistence for caching3. Enable Redis persistence for caching

4. Consider MySQL read replicas for scaling4. Consider MySQL read replicas for scaling

### Resource allocation:### Resource allocation:

- **WordPress**: 2 CPU cores, 1GB RAM per replica- **WordPress**: 2 CPU cores, 1GB RAM per replica

- **MySQL**: 2 CPU cores, 1GB RAM (adjust based on data size)- **MySQL**: 2 CPU cores, 1GB RAM (adjust based on data size)

- **Redis**: 0.5 CPU cores, 256MB RAM- **Redis**: 0.5 CPU cores, 256MB RAM

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
