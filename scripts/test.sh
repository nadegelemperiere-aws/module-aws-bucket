#!/bin/bash
# -------------------------------------------------------
# Copyright (c) [2022] Nadege Lemperiere
# All rights reserved
# -------------------------------------------------------
# Module to deploy an aws bucket with all the secure
# components required
# Bash script to tests in a container
# -------------------------------------------------------
# Nadège LEMPERIERE, @13 january 2022
# Latest revision: 19 november 2023
# -------------------------------------------------------

# Retrieve absolute path to this script
script=$(readlink -f $0)
scriptpath=`dirname $script`

# Launch tests in docker container
docker run  -it --rm \
            --volume $scriptpath/../:/home/test/module:rw \
            --volume $scriptpath/../../vaul-aws/:/home/test/vault \
            --env VAULT_KEY=$VAULT_KEY \
            --workdir /home/test/module \
            nadegelemperiere/terraform-python-awscli:v3.0.0 \
            ./scripts/robot.sh -k VAULT_KEY $@
