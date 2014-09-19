docker-reviewboard
==================

Dockerized reviewboard. This container follows Docker's best practices, and DOES NOT include sshd, supervisor, apache2, or any other services except the reviewboard itself which is run with ```uwsgi```.

The requirements are PostgreSQL and memcached, you can use either dockersized versions of them, or external ones, e.g. installed on the host machine, or even third-party machines.

Below a

## Quickstart. Run dockerized reviewboard with all dockerized dependencies.

    # Install postgres
    docker run -d --name rb-postgres postgres
    docker run -it --link rb-postgres:postgres --rm postgres sh -c 'exec createuser reviewboard -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'
    docker run -it --link rb-postgres:postgres --rm postgres sh -c 'exec createdb reviewboard -O reviewboard -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'

    # Install memcached
    docker run --name rb-memcached -d -p 11211 sylvainlasnier/memcached

    # Run reviewboard
    docker run -it --link rb-postgres:pg --link rb-memcached:memcached -p 8000:8000 ikatson/reviewboard

## Build yourself if you want.

If you want to build this yourself, just run this:

    docker build -t 'ikatson/reviewboard' git://github.com/ikatson/docker-reviewboard.git

## Dependencies

### Install PostgreSQL

You can install postgres either into a docker container, or whereever else.

1. Example: install postgres into a docker container, and create a database for reviewboard.

        docker run -d --name some-postgres postgres

        # Create the database and user for reviewboard
        docker run -it --link some-postgres:postgres --rm postgres sh -c 'exec createuser reviewboard -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'
        docker run -it --link some-postgres:postgres --rm postgres sh -c 'exec createdb reviewboard -O reviewboard -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'

2. Example: install postgres into the host machine

        apt-get install postgresql-server

        # Uncomment this to make postgres listen
        # echo "listen_addresses = '*'" >> /etc/postgresql/VERSION/postgresql.conf
        # invoke-rc.d postgresql restart
        sudo -u postgres createuser reviewboard
        sudo -u postgres createdb reviewboard -O reviewboard
        sudo -u postgres psql -c "alter user reviewboard set password to 'SOME_PASSWORD'"

### Install memcached

1. Example: install into a docker container

        docker run --name memcached -d -p 11211 sylvainlasnier/memcached

1. Example: install locally on Debian/Ubuntu.

        apt-get install memcached

   Don't forget to make it listen on needed addresses by editing /etc/memcached.conf, but be careful not to open it for the whole world.

### Run reviewboard

If you installed postgres and memcached into the host machine, or even on any other machine, the container accepts the following environment variables:

- **PGHOST** - the postgres host. Defaults to the value of PG_PORT_5432_TCP_ADDR.
- **PGPORT** - the postgres port. Defaults to the value of PG_PORT_5432_TCP_PORT, or 5432, if it's empty.
- **PGUSER** - the postgres user. Defaults to reviewboard.
- **MEMCACHED** - memcache address in format *host:port*. Defaults to the value from linked "memcached" container.
- **DOMAIN** - defaults to localhost.
- **DEBUG** - if set, the django server will be launched in debug mode.

Also, uwsgi accepts a any environment variables for it's configuration
E.g. ```-e UWSGI_PROCESSES=10``` will create 10 reviewboard processes.

1. Example. Run with dockerized postgres and memcached from above, expose on port 8000:

        docker run -it --link some-postgres:pg --link memcached:memcached -p 8000:8000 ikatson/reviewboard

1. Example. Run with postgres and memcached installed on the host machine.

        DOCKER_HOST_IP=$( ip addr | grep 'inet 172.1' | awk '{print $2}' | sed 's/\/.*//')

        docker run -it -p 8000:8080 -e PGHOST="$DOCKER_HOST_IP" -e PGPASSWORD=123 -e PGUSER=reviewboard -e MEMCACHED="$DOCKER_HOST_IP":11211 ikatson/reviewboard

1. Go to the url, e.g. ```http://localhost:8000/```, and login as ```admin:admin```, change the password and you are all set!
