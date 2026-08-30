# Inception — User Documentation

## 1. Introduction

This document explains how to use and manage the Inception infrastructure as an end user or administrator.

The project provides a WordPress website running through a Docker-based infrastructure composed of several services.

---

## 2. Services Provided

The stack contains the following main services:

### NGINX

NGINX is the entry point of the infrastructure.

It:

* Accepts HTTPS connections.
* Uses TLS certificates to secure communication.
* Receives requests from the web browser.
* Forwards PHP requests to WordPress/PHP-FPM.

NGINX is the only service directly accessible from outside the Docker network.

### WordPress

WordPress provides the website and its administration interface.

It runs using PHP-FPM and communicates with MariaDB to store and retrieve website data.

### MariaDB

MariaDB is the database server used by WordPress.

It stores information such as:

* Users
* Posts
* Pages
* WordPress settings
* Plugin and theme information

The database is stored in a persistent Docker volume.

---

# 3. Starting the Project

From the root directory of the project, run:

```bash
make
```

This builds the required Docker images and starts the infrastructure.

You can also start the project manually with Docker Compose:

```bash
cd srcs
docker compose up -d --build
```

To verify that the containers are running:

```bash
docker ps
```

You should see the project's containers running.

---

# 4. Stopping the Project

To stop the infrastructure:

```bash
make down
```

or:

```bash
cd srcs
docker compose down
```

Stopping the containers does not normally remove the persistent volumes, so website and database data can remain available when the project is started again.

---

# 5. Accessing the Website

The website is accessed through HTTPS.

The domain is configured in:

```text
srcs/.env
```

For example:

```env
DOMAIN_NAME=your_login.42.fr
```

The website can then be accessed from a browser at:

```text
https://your_login.42.fr
```

The domain must resolve to the machine running the project.

On a local machine, this may require an entry in `/etc/hosts`:

```text
127.0.0.1 your_login.42.fr
```

The exact IP address depends on where the project is running.

---

# 6. Accessing the WordPress Administration Panel

The WordPress administration panel is available at:

```text
https://your_login.42.fr/wp-admin/
```

Log in using the WordPress administrator credentials configured during the installation.

After authentication, the administrator can:

* Create and edit posts.
* Manage pages.
* Manage users.
* Install and configure themes.
* Manage plugins.
* Change WordPress settings.

---

# 7. Credentials

Sensitive credentials are stored separately from the main application configuration.

The project contains:

```text
secrets/
├── credentials.txt
├── db_password.txt
└── db_root_password.txt
```

### Database password

The database user password is stored in:

```text
secrets/db_password.txt
```

### Database root password

The MariaDB root password is stored in:

```text
secrets/db_root_password.txt
```

### Other credentials

Additional credentials can be stored in:

```text
secrets/credentials.txt
```

The exact content of these files depends on the configuration of the project.

**Do not commit real passwords or other sensitive credentials to a public Git repository.**

---

# 8. Checking the Services

## Check running containers

Run:

```bash
docker ps
```

The expected services should be running.

---

## Check all containers

To also see stopped containers:

```bash
docker ps -a
```

---

## Check container logs

To inspect a service:

```bash
docker logs <container_name>
```

For example:

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

The actual container names may be prefixed by the Compose project name.

---

## Follow logs in real time

```bash
docker logs -f <container_name>
```

Press `Ctrl+C` to stop following the logs.

---

# 9. Checking Docker Volumes

List the Docker volumes:

```bash
docker volume ls
```

The WordPress and MariaDB volumes should exist after the infrastructure has been started.

You can inspect a volume with:

```bash
docker volume inspect <volume_name>
```

---

# 10. Checking the Docker Network

List Docker networks:

```bash
docker network ls
```

The project's Docker network should be present.

To inspect it:

```bash
docker network inspect <network_name>
```

This allows you to verify which containers are connected to the network.

---

# 11. Restarting the Project

If a service needs to be restarted:

```bash
cd srcs
docker compose restart
```

To restart only one service:

```bash
docker compose restart nginx
docker compose restart wordpress
docker compose restart mariadb
```

---

# 12. Rebuilding the Project

If the Dockerfiles or configuration files have changed:

```bash
make re
```

or manually:

```bash
cd srcs
docker compose down
docker compose up -d --build
```

---

# 13. Data Persistence

The project uses Docker volumes to keep important data outside the lifecycle of individual containers.

This means that removing and recreating a container does not necessarily remove its data.

The main persistent data includes:

```text
MariaDB
    ↓
Database volume

WordPress
    ↓
WordPress data volume
```

As a result, restarting or rebuilding containers can preserve the website and database data.

---

# 14. Troubleshooting

### Containers are not running

Check:

```bash
docker ps -a
```

Then inspect the logs:

```bash
docker logs <container_name>
```

### Website cannot be reached

Check:

```bash
docker ps
```

Then verify:

* NGINX is running.
* Port `443` is available.
* The domain is correctly configured.
* The domain resolves to the correct machine.
* TLS configuration is correct.

### WordPress cannot connect to the database

Check:

```bash
docker logs wordpress
docker logs mariadb
```

Verify:

* MariaDB is running.
* Database credentials are correct.
* WordPress uses the correct database hostname.
* Both containers are connected to the same Docker network.

### Data disappeared

Check the volumes:

```bash
docker volume ls
```

Avoid using commands that remove volumes unless you intentionally want to delete persistent project data.

