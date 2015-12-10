docker-reviewboard
==================

Dockerized reviewboard. This container follows Docker's best practices, and DOES NOT include sshd, supervisor, apache2, or any other services except the reviewboard itself which is run with ```uwsgi```.

The requirements are mysql and memcached, you can use either dockersized versions of them, or external ones, e.g. installed on the host machine, or even third-party machines.

## Quickstart. Run dockerized reviewboard with all dockerized dependencies, and persistent data in a docker container.

    cd docker-reviewboard && docker-compose up

After that, go the url, e.g. ```http://localhost:8000/```, login as ```admin:admin```, change the admin password, and change the location of your SMTP server so that the reviewboard can send emails. You are all set!

For details, read below.

## Build yourself if you want.

If you want to build this yourself, just run this:

    docker build -t 'leibniz137/reviewboard' git://github.com/Leibniz137/docker-reviewboard.git

### Memcached

   Don't forget to make it listen on needed addresses by editing /etc/memcached.conf, but be careful not to open memcached for the whole world.

## Run reviewboard

This container has two volume mount-points:

- ```/.ssh``` - The default path to where reviewboard stores it's ssh keys.
- ```/media``` - The default path to where reviewboard stores uploaded media.

The container accepts the following environment variables:

- ```MYSQL_HOST``` - the mysql host. Defaults to the value of ```MYSQL_PORT_3306_TCP_ADDR```, provided by the ```mysql``` linked container.
- ```MYSQL_PORT``` - the mysql port. Defaults to the value of ```MYSQL_PORT_3306_TCP_ADDR```, provided by the ```mysql``` linked container, or 3306, if it's empty.
- ```MYSQL_USER``` - the mysql user. Defaults to ```reviewboard```.
- ```MYSQL_DATABASE``` - the mysql database. Defaults to ```reviewboard```.
- ```MYSQL_PASSWORD``` - the mysql password. Defaults to ```reviewboard```.
- ```MYSQL_ROOT_PASSWORD``` - the root mysql password. Defaults to ```reviewboard```.
- ```MEMCACHED``` - memcache address in format ```host:port```. Defaults to the value from linked ```memcached``` container.
- ```DOMAIN``` - defaults to ```localhost```.
- ```DEBUG``` - if set, the django server will be launched in debug mode.

Also, uwsgi accepts environment prefixed with ```UWSGI_``` for it's configuration
E.g. ```-e UWSGI_PROCESSES=10``` will create 10 reviewboard processes.


### Container SMTP settings.

You should also change SMTP settings, so that the reviewboard can send emails. A good way to go is to set this to docker host's internal IP address, usually, ```172.17.42.1```).

Don't forget to setup you mail agent to accept emails from docker.

For example, if you use ```postfix```, you should change ```/etc/postfix/main.cf``` to contain something like the lines below:

    mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 172.17.0.0/16
    inet_interfaces = 127.0.0.1,172.17.42.1
