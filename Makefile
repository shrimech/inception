DISTRO := $(shell . /etc/os-release && echo $$ID)



.PHONY: all
all:
	mkdir -p /home/shrimech/data/mariadb
	mkdir -p /home/shrimech/data/wordpress

	sudo rm -rf /var/lib/docker/volumes/srcs_mariadb_data
	sudo rm -rf /var/lib/docker/volumes/srcs_wordpress_data

	sudo mkdir -p /var/lib/docker/volumes/srcs_mariadb_data
	sudo mkdir -p /var/lib/docker/volumes/srcs_wordpress_data

	sudo ln -s /home/shrimech/data/mariadb \
		/var/lib/docker/volumes/srcs_mariadb_data/_data

	sudo ln -s /home/shrimech/data/wordpress \
		/var/lib/docker/volumes/srcs_wordpress_data/_data
	docker compose -f ./srcs/docker-compose.yml up -d --build 
.PHONY: down
down:
	docker compose -f srcs/docker-compose.yml down



.PHONY: clean
clean:
	sudo rm -rf /home/shrimech/data/mariadb
	sudo rm -rf /home/shrimech/data/wordpress
	docker compose -f srcs/docker-compose.yml down -v



.PHONY:fclean
fclean: clean
	docker system prune -af
	sudo rm -rf /home/shrimech/data


.PHONY: re
re: fclean all


.PHONY: install
install:
	make $(DISTRO)

.PHONY: debian
debian:
	sudo apt update
	sudo apt install -y docker.io docker-compose
	sudo systemctl enable --now docker
	sudo usermod -aG docker $(USER)
	@echo "Docker installed."
	@echo "Log out and log back in for the docker group to take effect."


.PHONY: ubuntu
ubuntu:
	sudo apt update
	sudo apt install -y docker.io docker-compose
	sudo systemctl enable --now docker
	sudo usermod -aG docker $(USER)
	@echo "Docker installed."
	@echo "Log out and log back in for the docker group to take effect."

.PHONY: arch
arch:
	sudo pacman -Sy --needed docker docker-compose
	sudo systemctl enable --now docker
	sudo usermod -aG docker $(USER)
	@echo "Docker installed."
	@echo "Log out and log back in for the docker group to take effect."

.PHONY: void
void:
	sudo xbps-install -Sy docker docker-compose
	sudo ln -sf /etc/sv/docker /var/service/docker
	sudo usermod -aG docker $(USER)
	@echo "Docker installed."
	@echo "Log out and log back in for the docker group to take effect."

.PHONY: fedora
fedora:
	sudo dnf install -y docker docker-compose
	sudo systemctl enable --now docker
	sudo usermod -aG docker $(USER)
	@echo "Docker installed."
	@echo "Log out and log back in for the docker group to take effect."


.PHONY: distro
distro:
	@echo $(DISTRO)