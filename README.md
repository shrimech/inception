*This project has been created as part of the 42 curriculum by shrimech.*

# Inception

## Description

**Inception** is a system administration project from the 42 curriculum focused on containerization, Docker, networking, volumes, environment configuration, and service orchestration.

The goal of this project is to build a small infrastructure composed of multiple services running inside separate Docker containers. Each service is built from a custom Dockerfile and orchestrated using Docker Compose.

The infrastructure includes:

* **NGINX** — acts as the entry point of the infrastructure and provides HTTPS access using TLS.
* **WordPress + PHP-FPM** — provides the website and application layer.
* **MariaDB** — stores the WordPress database.
* **Docker volumes** — provide persistent storage for the database and WordPress files.
* **Docker networks** — allow containers to communicate with each other in an isolated environment.
* **Docker secrets** — store sensitive information such as database passwords outside environment variables.

The project is designed to demonstrate how multiple isolated services can work together to form a complete infrastructure.

The architecture can be represented as follows:

```text
                    Internet / Browser
                           │
                           │ HTTPS
                           ▼
                    ┌──────────────┐
                    │    NGINX     │
                    │   :443 only  │
                    └──────┬───────┘
                           │
                           │ Docker Network
                           ▼
                    ┌──────────────┐
                    │  WordPress   │
                    │   PHP-FPM    │
                    └──────┬───────┘
                           │
                           │ Docker Network
                           ▼
                    ┌──────────────┐
                    │   MariaDB    │
                    └──────────────┘

          Persistent Data
          ┌──────────────────────────┐
          │ Docker Volumes           │
          │                          │
          │ • WordPress files        │
          │ • MariaDB database       │
          └──────────────────────────┘
```

---

## Project Structure

```text
.
├── Makefile
├── README.md
├── secrets
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
│
└── srcs
    ├── .env
    ├── docker-compose.yml
    │
    └── requirements
        ├── bonus/
        ├── mariadb/
        │   ├── conf/
        │   ├── tools/
        │   ├── Dockerfile
        │   └── .dockerignore
        │
        ├── nginx/
        │   ├── conf/
        │   ├── tools/
        │   ├── Dockerfile
        │   └── .dockerignore
        │
        └── wordpress/
            ├── conf/
            ├── tools/
            ├── Dockerfile
            └── .dockerignore
```

---

# Instructions

## Requirements

The project requires:

* Docker
* Docker Compose
* GNU Make

You can verify that Docker and Docker Compose are installed with:

```bash
docker --version
docker compose version
```

## Configuration

Before starting the infrastructure, configure the environment variables inside:

```text
srcs/.env
```

Example:

```env
DOMAIN_NAME=shrimech.42.fr

MYSQL_DATABASE=wordpress
MYSQL_USER=wordpress
```

Sensitive credentials are stored in the `secrets/` directory.

Example:

```text
secrets/
├── credentials.txt
├── db_password.txt
└── db_root_password.txt
```

These files should contain the required credentials without exposing them directly inside Dockerfiles or Docker Compose configuration.

## Building and Starting the Infrastructure

From the root of the repository:

```bash
make
```

or:

```bash
make all
```

This builds the Docker images and starts the infrastructure.

The containers can also be started manually using Docker Compose:

```bash
cd srcs
docker compose up --build
```

To run the containers in detached mode:

```bash
docker compose up -d --build
```

## Stopping the Infrastructure

To stop the containers:

```bash
make down
```

Or manually:

```bash
cd srcs
docker compose down
```

## Cleaning

Depending on the implementation of the `Makefile`, the following commands can be used:

```bash
make clean
```

To remove containers, images, volumes, and networks:

```bash
make fclean
```

> The exact behavior of `clean` and `fclean` depends on the implementation of the project's Makefile.

---

# Technical Choices

## Docker

Docker is used to isolate each service into its own container.

Instead of installing NGINX, WordPress, PHP-FPM, and MariaDB directly on the host machine, each service runs in an independent environment with its own configuration.

Each service has its own:

* Dockerfile
* Configuration files
* Startup scripts
* Dependencies

The services are orchestrated using Docker Compose.

This approach makes the infrastructure reproducible: the same configuration can be built and executed on another compatible system.

---

## Sources Included in the Project

The project contains custom Docker configurations for the main services:

### NGINX

NGINX acts as the public entry point.

Its responsibilities include:

* Listening on port `443`
* Handling HTTPS connections
* Managing TLS certificates
* Forwarding PHP requests to the WordPress PHP-FPM service

NGINX is the only service directly exposed to the outside network.

### WordPress

WordPress provides the web application.

The WordPress container uses PHP-FPM instead of running its own web server.

It communicates with:

* NGINX for incoming requests
* MariaDB for database access

WordPress files are stored in a persistent Docker volume.

### MariaDB

MariaDB provides the database service used by WordPress.

The database stores:

* WordPress users
* Posts
* Configuration
* Application data

MariaDB data is stored in a persistent Docker volume so that the data survives container recreation.

---

# Design Choices

## One Service per Container

Each major service runs in its own container:

* NGINX
* WordPress
* MariaDB

This separation improves:

* Isolation
* Maintainability
* Portability
* Scalability

Each container has a specific responsibility.

For example, NGINX handles HTTP/HTTPS traffic, while MariaDB only handles database operations.

---

## Custom Docker Images

The images are built using custom Dockerfiles rather than using pre-built service images directly.

This makes the configuration explicit and allows the infrastructure to control:

* Installed packages
* Configuration files
* Startup behavior
* Permissions
* Environment configuration

---

## Persistent Storage

Docker volumes are used to store data that must survive container deletion.

Two important types of persistent data are:

* WordPress files
* MariaDB database files

Without persistent storage, recreating a container could result in data loss.

---

## Internal Networking

The containers communicate through a Docker network.

Docker provides internal DNS resolution, allowing services to communicate using service names.

For example:

```text
WordPress → mariadb
NGINX → wordpress
```

The containers do not need to expose all internal ports to the host machine.

Only the required public service is exposed.

---

# Comparisons

## Virtual Machines vs Docker

### Virtual Machines

A Virtual Machine emulates a complete operating system environment.

A VM typically contains:

```text
Hardware
   │
Hypervisor
   │
Guest Operating System
   │
Applications
```

Each VM has its own:

* Operating system
* Kernel
* System libraries
* Applications

### Docker Containers

Docker containers share the host kernel.

```text
Hardware
   │
Host Operating System
   │
Docker Engine
   │
Containers
```

Containers include only the application and the dependencies required to run it.

### Comparison

| Virtual Machines                             | Docker Containers                             |
| -------------------------------------------- | --------------------------------------------- |
| Includes a complete guest OS                 | Shares the host kernel                        |
| Usually heavier                              | Usually lighter                               |
| Slower startup                               | Faster startup                                |
| More resource consumption                    | Lower resource consumption                    |
| Strong OS-level isolation                    | Process-level isolation                       |
| Larger disk usage                            | Smaller images                                |
| Good for running different operating systems | Good for packaging and deploying applications |

Docker is useful for this project because each service can run in an isolated environment without requiring a complete virtual machine.

---

## Secrets vs Environment Variables

### Environment Variables

Environment variables are commonly used for configuration:

```env
MYSQL_USER=wordpress
MYSQL_DATABASE=wordpress
```

They are useful for non-sensitive configuration.

However, environment variables can potentially be exposed through:

* Container inspection
* Process environments
* Logs
* Misconfigured debugging tools

### Docker Secrets

Secrets are intended for sensitive information such as:

* Passwords
* API keys
* Database credentials

Examples:

```text
db_password.txt
db_root_password.txt
credentials.txt
```

The application can read the secret from a file rather than storing the password directly inside the Dockerfile or source code.

### Comparison

| Secrets                                          | Environment Variables                        |
| ------------------------------------------------ | -------------------------------------------- |
| Designed for sensitive data                      | Mainly configuration data                    |
| Stored separately from application configuration | Passed directly into the process environment |
| Can be mounted as files                          | Available as environment variables           |
| Better separation of credentials                 | Easier for normal configuration              |
| Suitable for passwords and private data          | Suitable for names, ports, domains, etc.     |

For this project:

```text
Environment Variables → domain names, database names, usernames
Secrets               → passwords and credentials
```

---

## Docker Network vs Host Network

### Docker Network

A Docker network provides communication between containers.

For example:

```text
NGINX ──────► WordPress ──────► MariaDB
```

Containers can communicate internally using their service names.

Advantages include:

* Service isolation
* Internal DNS
* Controlled communication
* Reduced exposure of internal services

### Host Network

With host networking, a container directly uses the host machine's network stack.

This means the container has less network isolation.

For example, ports used by the container can directly conflict with ports used by the host.

### Comparison

| Docker Network                                | Host Network                                |
| --------------------------------------------- | ------------------------------------------- |
| Network isolation                             | Uses host network directly                  |
| Built-in service discovery                    | No container network isolation              |
| Internal services can remain private          | Services are closer to host networking      |
| Better separation between services            | Possible port conflicts                     |
| Recommended for multi-container architectures | Useful for specific networking requirements |

The Inception infrastructure uses a Docker network so that WordPress and MariaDB can communicate internally without exposing unnecessary ports to the host.

---

## Docker Volumes vs Bind Mounts

### Docker Volumes

Docker volumes are managed by Docker.

They are designed for persistent container data.

Example:

```text
MariaDB container
        │
        ▼
Docker Volume
        │
        ▼
Persistent database data
```

Advantages:

* Managed by Docker
* Independent from the container lifecycle
* Suitable for persistent application data
* Easier to move between containers

### Bind Mounts

A bind mount connects a specific directory from the host machine to a container.

Example:

```text
Host directory
      │
      ▼
Bind Mount
      │
      ▼
Container directory
```

Changes on the host are immediately visible inside the container.

Bind mounts are useful for:

* Development
* Source code synchronization
* Direct access to host files

### Comparison

| Docker Volumes                                 | Bind Mounts                             |
| ---------------------------------------------- | --------------------------------------- |
| Managed by Docker                              | Managed by the host filesystem          |
| Docker chooses or manages the storage location | Uses a specific host path               |
| Better for persistent application data         | Useful for development                  |
| More portable                                  | Depends on the host directory structure |
| Easier to manage with Docker commands          | Direct host access                      |

For this project, persistent application data is stored using Docker volumes or Docker-managed persistent storage, depending on the project's required configuration.

---

# Usage

After starting the infrastructure, open the configured domain in your browser:

```text
https://shrimech.42.fr
```

NGINX receives the HTTPS request and forwards it to WordPress.

The request flow is:

```text
Browser
   │
   │ HTTPS :443
   ▼
NGINX
   │
   │ FastCGI
   ▼
WordPress / PHP-FPM
   │
   │ SQL
   ▼
MariaDB
```

---

# Useful Docker Commands

Check running containers:

```bash
docker ps
```

Check all containers:

```bash
docker ps -a
```

Check Docker images:

```bash
docker images
```

Check Docker volumes:

```bash
docker volume ls
```

Check Docker networks:

```bash
docker network ls
```

View container logs:

```bash
docker logs <container_name>
```

Open a shell inside a running container:

```bash
docker exec -it <container_name> bash
```

If Bash is not available:

```bash
docker exec -it <container_name> sh
```

---

# Resources

## Docker

* Docker Documentation
* Docker Engine Documentation
* Docker Compose Documentation
* Docker Networking Documentation
* Docker Volumes Documentation
* Docker Storage Documentation
* Dockerfile Reference

Useful starting points:

* Docker: https://docs.docker.com/
* Docker Compose: https://docs.docker.com/compose/
* Docker Networking: https://docs.docker.com/network/
* Docker Volumes: https://docs.docker.com/engine/storage/volumes/
* Dockerfile Reference: https://docs.docker.com/reference/dockerfile/

## NGINX

* NGINX Documentation

* NGINX Beginner's Guide

* NGINX SSL/TLS Configuration

* NGINX: https://nginx.org/en/docs/

## WordPress

* WordPress Documentation

* WordPress Command Line Interface documentation

* WordPress configuration documentation

* WordPress Developer Resources: https://developer.wordpress.org/

## MariaDB

* MariaDB Documentation

* MariaDB Server Documentation

* MariaDB: https://mariadb.com/kb/en/documentation/

## Additional Learning Resources

* 42 Network — Inception project documentation and subject
* Docker Deep Dive by Nigel Poulton
* Official Docker tutorials
* Linux namespaces and cgroups documentation

---

# AI Usage

Artificial intelligence tools were used as a learning and development assistant during this project.

AI was used for:

* Explaining Docker concepts and architecture
* Understanding the differences between Docker, containers, container runtimes, and virtual machines
* Learning about Docker networking and volumes
* Understanding Dockerfiles and Docker Compose configuration
* Debugging configuration and container-related errors
* Explaining NGINX, PHP-FPM, WordPress, and MariaDB interactions
* Reviewing shell scripts and configuration files
* Improving documentation and the structure of this README

AI-generated suggestions were reviewed, understood, tested, and adapted before being integrated into the project.

AI was **not used as a replacement for understanding the project requirements**. The final implementation, configuration choices, testing, and validation remain the responsibility of the project author.

---

# Project Goals

Through this project, the following concepts are explored:

* Docker
* Containerization
* Dockerfiles
* Docker Compose
* Linux processes
* Networking
* TLS/HTTPS
* Reverse proxies
* PHP-FPM
* Database services
* Persistent storage
* Docker volumes
* Environment variables
* Secrets management
* Service orchestration
* Infrastructure design

---

## License

This project was developed as part of the **42 curriculum** and is intended for educational purposes.
