# Bash Script for a Docker Compose Development Environment

This repository contains a script to set up a local development environment using Docker Compose. It includes services such as PostgreSQL, pgAdmin, MailHog, and Redis.

## Prerequisites

Before starting, make sure you have Docker and Docker Compose installed on your system. For installations on Linux or WSL2 (Windows Subsystem for Linux), you can follow the official guides:

- [Install Docker](https://docs.docker.com/engine/install/)
- [Install Docker Compose](https://docs.docker.com/compose/install/)

## Initial Setup

1. Clone the repository to your local machine:

   ```bash
   git clone https://github.com/wiliancirillo/start-environment.git
   cd start-environment
   ```

2. Grant execution permission to the startup script:

   ```bash
   chmod +x start-environment.sh
   ```

3. Edit the environment variables as needed in the `start-environment.sh` script. By default, the script uses your system username as the PostgreSQL user and sets the default email as `me@<your_user>.io`.

## Running the Environment

To start all services defined in the `docker-compose.yml`, execute the script:

```bash
./start-environment.sh
```

This will start the containers in the background. You can check the status of the containers with the command:

```bash
docker-compose ps
```

## Included Services

- **PostgreSQL**: Relational database.
- **pgAdmin**: Web interface for managing PostgreSQL.
- **MailHog**: Test SMTP server with an interface for viewing messages.
- **Redis**: In-memory data structure store, used as a database, cache, and message broker.

## Ports

The following ports are exposed and can be accessed through your browser or database client:

- **PostgreSQL**: 5432
- **pgAdmin**: [http://localhost:9090](http://localhost:9090)
- **MailHog**: [http://localhost:8025](http://localhost:8025)
- **Redis**: 6379

## Connecting to PostgreSQL

The PostgreSQL configuration in Docker Compose allows password-free connections due to the authentication method set to `trust`. This means you can connect to the database without needing a password, which facilitates development and local testing.

### Using pgAdmin

You can access pgAdmin through your browser to manage your PostgreSQL database. Here are the steps to connect to pgAdmin and PostgreSQL:

1. Open your browser and access [http://localhost:9090](http://localhost:9090).
2. Access is made automatically without the need for login, as configured in the environment variables (`PGADMIN_CONFIG_MASTER_PASSWORD_REQUIRED: "False"`).
3. Once logged in, add a new connection to the PostgreSQL server:
   - Click on 'Add New Server'.
   - In the 'General' tab, give the server a name.
   - In the 'Connection' tab:
     - **Hostname/address**: `db`
     - **Port**: `5432`
     - **Maintenance database**: `postgres` or the same value as `$POSTGRES_USER`
     - **Username**: the value of `$POSTGRES_USER`, which is your system username.
     - **Password**: leave this field blank (due to the `trust` configuration).
   - Click on 'Save'.

### Using CLI

To connect via command line, you can use the `psql` client installed on your Linux/WSL2 machine:

```bash
psql -h localhost -p 5432 -U $POSTGRES_USER -d postgres
```

Replace `$POSTGRES_USER` with your actual username if necessary. Since authentication is by `trust`, you will not be prompted to enter a password.

### Scripts and Development Tools

You can also directly connect your application or development tool to PostgreSQL. Configure the connection string as follows:

- **Host**: `host.docker.internal` or `localhost`
- **Port**: `5432`
- **Database**: `postgres`
- **User**: `$POSTGRES_USER` (your system username)
- **Password**: (leave blank)

Ensure that any application that will connect to the database is on the same Docker network or configured to allow connections from the local host.

## Ending the Environment

To stop and remove all services, use:

```bash
docker-compose down
# or
docker-compose down -v # clears the volumes, for a complete removal of data
```
