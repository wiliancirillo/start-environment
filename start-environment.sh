#!/bin/bash

# Função para perguntar ao usuário se quer continuar com o valor padrão ou fornecer um novo
ask_user() {
  local var_name=$1
  local default_value=$2
  local prompt=$3
  read -p "$prompt [$default_value]: " input
  if [ -z "$input" ]; then
    echo "$default_value"
  else
    echo "$input"
  fi
}

# Função para perguntar ao usuário se deseja incluir um serviço
ask_include_service() {
  local service_name=$1
  while true; do
    read -p "Incluir o serviço $service_name? (s/n): " yn
    case $yn in
      [Ss]* ) echo "yes"; break;;
      [Nn]* ) echo "no"; break;;
      * ) echo "Por favor, responda s (sim) ou n (não).";;
    esac
  done
}

# Obtém o username atual
current_user=$(whoami)

# Pergunta ao usuário se deseja usar o username atual ou fornecer um novo
POSTGRES_USER=$(ask_user "POSTGRES_USER" "$current_user" "Digite o nome de usuário do PostgreSQL")

# Pergunta ao usuário o nome do projeto
PROJECT_NAME=$(ask_user "PROJECT_NAME" "projects" "Digite o nome do projeto")

# Define o email padrão
DEFAULT_EMAIL="$POSTGRES_USER@projects.io"

# Pergunta ao usuário sobre cada serviço
include_postgres=$(ask_include_service "Postgres")
include_pgadmin=$(ask_include_service "pgAdmin")
include_mailhog=$(ask_include_service "Mailhog")
include_redis=$(ask_include_service "Redis")

# Cria o arquivo docker-compose.yml
cat <<EOF > docker-compose.yml
---
name: $PROJECT_NAME
services:
EOF

if [ "$include_postgres" == "yes" ]; then
cat <<EOF >> docker-compose.yml
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
      - $PROJECT_NAME
EOF
fi

if [ "$include_pgadmin" == "yes" ]; then
cat <<EOF >> docker-compose.yml
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
      - $PROJECT_NAME
EOF
fi

if [ "$include_mailhog" == "yes" ]; then
cat <<EOF >> docker-compose.yml
  mailhog:
    image: mailhog/mailhog:latest
    container_name: localmail
    logging: 
       driver: "none"
    ports:
      - "1025:1025"
      - "8025:8025"
    networks:
      - $PROJECT_NAME	
EOF
fi

if [ "$include_redis" == "yes" ]; then
cat <<EOF >> docker-compose.yml
  redis:
    image: redis:latest
    container_name: redis
    ports:
      - "6379:6379"
    networks:
      - $PROJECT_NAME
EOF
fi

cat <<EOF >> docker-compose.yml
volumes:
  postgres:

networks:
  $PROJECT_NAME:
    driver: bridge
EOF

# Inicia os containers usando Docker Compose
docker-compose up -d
