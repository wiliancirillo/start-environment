#!/bin/bash

# Sets the username as the default system user
POSTGRES_USER=$(whoami)
DEFAULT_EMAIL="me@$POSTGRES_USER.io"

# Creates the docker-compose.yml file
cat <<EOF > docker-compose.yml
---
name: projects
services:
  postgres:
    image: postgres:latest
    container_name: db
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: $POSTGRES_USER
      POSTGRES_HOST_AUTH_METHOD: "trust"
    volumes:
      - ~/.local-storage:/var/lib/postgresql/data
    networks: 
      - database
  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: dbms
    environment:
      PGADMIN_DEFAULT_EMAIL: $DEFAULT_EMAIL
      PGADMIN_DEFAULT_PASSWORD: $POSTGRES_USER 
      PGADMIN_CONFIG_SERVER_MODE: "False"
      PGADMIN_CONFIG_MASTER_PASSWORD_REQUIRED: "False"
    ports:
      - "9090:80"
    depends_on:
      - postgres
    networks:
      - database
  mailhog:
    image: mailhog/mailhog:latest
    container_name: localmail
    logging: 
       driver: "none"
    ports:
      - "1025:1025"
      - "8025:8025"
    networks:
      - database	
  redis:
    image: redis:latest
    container_name: redis
    ports:
      - "6379:6379"
    networks:
      - database
volumes:
  postgres:

networks:
  database:
    driver: bridge
EOF

# Starts the PostgreSQL container using Docker Compose
docker-compose up -d

