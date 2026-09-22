# Developer Documentation

This document describes how to set up the development environment, build and launch the project, manage containers and volumes, and understand where project data is stored.

## Prerequisites

- Linux (tested on common distributions)
- Docker
- Docker Compose (v2 `docker compose` CLI or `docker-compose`)
- GNU Make

Install Docker and Docker Compose on Debian/Ubuntu:

```bash
sudo apt update
sudo apt install -y docker.io docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
```

Log out and log back in (or restart your shell) to apply the `docker` group membership.

## Configuration & Secrets

- Environment variables are in `srcs/.env`. Copy the example values and update them for your environment if needed.
- Sensitive credentials are stored in the `secrets/` directory: `credentials.txt`, `db_password.txt`, and `db_root_password.txt`. Ensure these files exist before launching the project.

Example minimal `srcs/.env`:

```env
DOMAIN_NAME=example.local
MYSQL_DATABASE=wordpress
MYSQL_USER=wordpress
MYSQL_PASSWORD=$(cat ../secrets/db_password.txt)
MYSQL_ROOT_PASSWORD=$(cat ../secrets/db_root_password.txt)
```

Adjust file paths and variable names to your local layout as needed.

## Build & Launch (Makefile)

From the project root you can use the `Makefile` targets.

- Start (build + run):

```bash
make
```

- Stop:

```bash
make down
```

- Clean persistent data and stop containers:

```bash
make clean
```

- Full clean (remove images, volumes, other Docker artifacts):

```bash
make fclean
```

If you prefer to use Docker Compose directly:

```bash
cd srcs
docker compose up -d --build
# stop and remove containers + volumes
docker compose down -v
```

## Managing Containers & Images

- List running containers:

```bash
docker ps
```

- Stop and remove a container:

```bash
docker rm -f <container-name-or-id>
```

- Remove unused images and build cache:

```bash
docker system prune -af
```

- Build images without starting containers (for debugging builds):

```bash
cd srcs
docker compose build
```

## Volumes & Data Persistence

This project stores persistent data in Docker volumes (or optionally host bind mounts depending on `srcs/docker-compose.yml` configuration):

- WordPress files (uploads, plugins, themes): persisted in the `wordpress_data` volume.
- MariaDB database files: persisted in the `mariadb_data` volume.

By default these are Docker named volumes declared in `srcs/docker-compose.yml`. To inspect volumes:

```bash
docker volume ls
docker volume inspect <volume-name>
```

If your Compose uses host bind mounts (e.g. `/home/shrimech/data/*`), ensure the host directories exist before launching the project:

```bash
mkdir -p /home/shrimech/data/mariadb /home/shrimech/data/wordpress
```

Notes on persistence:
- Removing a volume with `docker volume rm` will permanently delete its contents.
- When using host bind mounts, files are written directly to the host path and survive container recreation.

## Troubleshooting

- "Conflict. The container name \"/mariadb\" is already in use": a previous container with the same name still exists. Remove it with:

```bash
docker rm -f mariadb
```

- "failed to populate volume: failed to mount local volume ... no such file or directory": a host bind path used by the Compose volume does not exist. Create it (see Volumes & Data Persistence above).

- Anonymous image IDs appear after rebuilds: ensure `srcs/docker-compose.yml` uses explicit project-scoped `image:` tags (e.g. `inception-nginx:latest`) so builds produce predictable image names.

## Where to look in the repo

- Compose configuration: `srcs/docker-compose.yml`
- Docker build contexts and Dockerfiles: `srcs/requirements/*/Dockerfile`
- Environment variables: `srcs/.env`
- Secrets: `secrets/`
- Make targets: `Makefile`

---

If you'd like, I can also:

- Commit suggested changes to `srcs/docker-compose.yml` to use project-scoped image names.
- Make `Makefile` idempotent by ensuring volumes/containers are cleaned before `up`.

Tell me which of those you'd like me to apply.
