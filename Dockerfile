# Zabbix version 2.4.7

# Pull base image
FROM ubuntu:xenial

MAINTAINER Nickolai Barnum <nbarnum@users.noreply.github.com>

# Install Zabbix and dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl \
                       wget \
                       monit \
                       snmp-mibs-downloader \
                       zabbix-agent \
                       zabbix-proxy-sqlite3 && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

RUN zcat /usr/share/zabbix-proxy-sqlite3/schema.sql.gz | \
    sqlite3 /var/lib/zabbix/zabbix.db

# Copy scripts, Monit config and Zabbix config into place
COPY monitrc                     /etc/monit/monitrc
COPY ./scripts/entrypoint.sh     /bin/docker-zabbix

# Fix permissions
RUN chmod 755 /bin/docker-zabbix && \
    chmod 600 /etc/monit/monitrc && \
    chown -R zabbix:zabbix /var/lib/zabbix

# Expose ports for
# * 10051 zabbix_proxy
EXPOSE 10051

# Will run `/bin/docker run`, which instructs
# monit to start zabbix_proxy.
ENTRYPOINT ["/bin/docker-zabbix"]
