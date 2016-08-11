#!/bin/bash

echo "---"
echo "$(date) - LE update script started"

readarray DOMAINS < /etc/letsencrypt/domains.conf
DOMAINS_COUNT=${#DOMAINS[@]}

if [ $DOMAINS_COUNT -gt 0 ]
then
    echo "Updating certificates"
    docker start -a letsencrypt-docker-gen

    echo "Updating H2O conf"
    docker-gen -onlyexposed /etc/docker-gen/templates/h2o.tmpl /etc/h2o/h2o.conf

    echo "Sending reload signal to H2O container"
    docker kill -s HUP h2o
else
    echo "No domains to update"
fi

echo "$(date) - Done!"
