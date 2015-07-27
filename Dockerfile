# Commentaire
FROM ubuntu:latest

MAINTAINER Nicolas Maire <trexmaster@trexmaster.fr>

#RUN dnf -y update && dnf -y install mariadb mariadb-server supervisor

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update

RUN apt-get -y install mariadb-client mariadb-server supervisor

RUN sed -i '/\[supervisord\]/a nodaemon=true' /etc/supervisor/supervisord.conf && \
    echo "[program:mariadb]" >> /etc/supervisor/conf.d/mariadb.conf && \
    echo "command=/opt/scripts/mariadb_startup.sh" >> /etc/supervisor/conf.d/mariadb.conf && \
#    echo "user=mysql" >> /etc/supervisor/conf.d/mariadb.conf && \
    mkdir -p /opt/scripts && \
    echo "#!/bin/bash" >> /opt/scripts/mariadb_startup.sh && \
    echo "/usr/bin/mysql_install_db" >> /opt/scripts/mariadb_startup.sh && \
    echo "/etc/init.d/mysql start" >> /opt/scripts/mariadb_startup.sh && \
    chmod a+x /opt/scripts/mariadb_startup.sh && \
    chown mysql:mysql /opt/scripts/mariadb_startup.sh && \
    echo "DELETE FROM mysql.user WHERE User='';" >> /opt/scripts/mariadb_secure.sql && \
    echo "DELETE FROM mysql.db WHERE Db LIKE 'test%';" >> /opt/scripts/mariadb_secure.sql && \
    echo "DROP DATABASE test;" >> /opt/scripts/mariadb_secure.sql && \
    echo "flush privileges;" >> /opt/scripts/mariadb_secure.sql && \
    chown mysql:mysql /opt/scripts/mariadb_secure.sql && \
    sed -i 's/bind-address\s*=\s*127\.0\.0\.1/bind-address=0\.0\.0\.0/' /etc/mysql/my.cnf

VOLUME ["/var/lib/mysql","/var/log/mysql","/var/log/supervisor"]

EXPOSE 3306

CMD ["/usr/bin/supervisord","-c","/etc/supervisor/supervisord.conf"]
