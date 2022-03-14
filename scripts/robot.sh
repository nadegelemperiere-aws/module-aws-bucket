#!/bin/bash
# -------------------------------------------------------
# TECHNOGIX
# -------------------------------------------------------
# Copyright (c) [2022] Technogix SARL
# All rights reserved
# -------------------------------------------------------
# Module to deploy an aws bucket with all the secure
# components required
# Bash script to launch robotframework tests
# -------------------------------------------------------
# Nadège LEMPERIERE, @13 january 2022
# Latest revision: 11 march 2022
# -------------------------------------------------------

# Retrieve absolute path to this script
script=$(readlink -f $0)
scriptpath=`dirname $script`

# Parse arguments from flags
args=""
while getopts s:l:d: flag
do
    case "${flag}" in
          s) args+=" --suite ${OPTARG}";;
          l) args+=" --loglevel ${OPTARG}";;
          d) args+=" --log ${OPTARG}/log.html --report ${OPTARG}/report.html";;
    esac
done

# Install required python packages
pip install --quiet -r $scriptpath/../requirements-test.txt

# Launch python scripts to setup terraform environment
python3 -m robot --variable vaultdatabase:$scriptpath/../../vault/database.kdbx   \
                 --variable vaultkey:$scriptpath/../../vault/database.key         \
                 $args                                                                      \
                 $scriptpath/../test/cases