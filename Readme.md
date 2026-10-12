# PHP Development Environment

Docker-based development environment for PHP projects, featuring Apache HTTPD, PHP-FPM/CLI, MySQL, and a Kafka cluster with monitoring UI.

## Services

| Service | Port | Description |
|---------|------|-------------|
| **httpd** | 80 | Apache 2.4 with mod_proxy_fcgi, serving PHP via PHP-FPM |
| **php8.4-cli** | — | PHP 8.4 CLI container (interactive shell) |
| **php8.4-fpm** | 9000 | PHP 8.4 FPM pool |
| **mysql** | 3306 | MySQL (latest) |
| **phpmyadmin** | 8080 | Database administration UI |
| **controller1–3** | 9093 | Kafka controller quorum (3 nodes) |
| **broker1–3** | 19092 / 29092 / 39092 | Kafka brokers (host ports) |
| **kafbat-ui** | 9080 | Kafka cluster dashboard |

## Directory Structure

```
.
├── environment/              # Docker configuration
│   ├── compose.yaml          # Docker Compose orchestration
│   ├── php/
│   │   ├── cli/              # PHP CLI Dockerfiles (7.4, 8.0, 8.4)
│   │   ├── fpm/              # PHP FPM Dockerfiles (7.4, 8.0, 8.4)
│   │   └── configs/          # php.ini and fpm pool configs per version
│   └── httpd/
│       ├── httpd.Dockerfile  # Apache base image
│       └── configs/
│           ├── httpd.conf    # Main Apache configuration
│           ├── php-fcgi/     # PHP version-specific FCGI configs
│           └── vhosts/       # Virtual host definitions
├── public_html/              # Project web root (mounted into containers)
├── data/
│   ├── db/                   # MySQL persistent data
│   ├── kafka/                # Kafka broker/controller logs
│   └── log/                  # Application logs (httpd, php)
└── Readme.md
```

## PHP Extensions

The PHP images are built with the following extensions:

- **Core:** gd (FreeType, JPEG, WebP), pdo_mysql, pdo_pgsql, zip, simplexml, mbstring
- **PECL:** amqp (RabbitMQ), xdebug, rdkafka (Apache Kafka)
- **CLI tools:** make, autoconf, gettext, gnupg, Composer (in FPM image)

## Quick Start

### 1. Build and start all services

```bash
cd environment
docker compose up --build -d
```

### 2. Access the services

- **Web application:** http://localhost
- **phpMyAdmin:** http://localhost:8080
- **Kafka UI:** http://localhost:9080

### 3. Run CLI commands

```bash
docker exec -it php8.4-cli bash
```

### 4. Stop services

```bash
cd environment
docker compose down
```

## Configuration

### PHP Version

By default, PHP 8.4 is active. Older versions (7.4, 8.0) are available but commented out in `compose.yaml` — uncomment the desired service block to switch.

### Virtual Hosts

Virtual hosts are defined in `environment/httpd/configs/vhosts/`. The default configuration includes:

- `localhost` — serves `DocumentRoot /var/www/html`
- `cl-helper.vhost` — serves Laravel-style app at `/var/www/html/cl-helper/public` (PHP 8.4)

Add new `.conf` files to the `vhosts/` directory and include them in `httpd.conf`.

### User UID/GID

Build arguments control the user inside containers. Override via environment:

```bash
UID=1001 GID=1001 docker compose up --build -d
```

### Kafka

Kafka uses 3 controllers and 3 brokers for high availability. Before running, increase inotify limits:

```bash
sudo sysctl fs.inotify.max_user_instances=512
sudo sysctl fs.inotify.max_user_watches=524288
```

Kafka brokers are exposed on host ports `19092`, `29092`, `39092`. Use any of these for client connections (e.g., `localhost:19092`).

## Logging

Logs are mounted to the host at `data/log/`:

- `data/log/httpd/` — Apache access and error logs
- `data/log/php/` — PHP-FPM error logs

## Network

All services share a Docker bridge network named `app-network`. Containers communicate via service names (e.g., `mysql:3306`, `broker1:9092`).
