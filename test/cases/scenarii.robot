# -------------------------------------------------------
# TECHNOGIX
# -------------------------------------------------------
# Copyright (c) [2022] Technogix SARL
# All rights reserved
# -------------------------------------------------------
# Robotframework test suite for module
# -------------------------------------------------------
# Nadège LEMPERIERE, @12 november 2021
# Latest revision: 12 november 2021
# -------------------------------------------------------


*** Settings ***
Documentation   A test case to check multiple subnets creation using module
Library         technogix_iac_keywords.terraform
Library         technogix_iac_keywords.keepass
Library         technogix_iac_keywords.s3
Library         ../keywords/data.py

*** Variables ***
${KEEPASS_DATABASE}                 ${vault_database}
${KEEPASS_KEY}                      ${vault_key}
${KEEPASS_GOD_KEY_ENTRY}            /engineering-environment/aws/aws-god-access-key
${KEEPASS_ACCOUNT_ENTRY}            /engineering-environment/aws/aws-account
${KEEPASS_GOD_USERNAME}             /engineering-environment/aws/aws-god-credentials
${REGION}                           eu-west-1

*** Test Cases ***
Prepare environment
    [Documentation]         Retrieve god credential from database and initialize python tests keywords
    ${god_access}           Load Keepass Database Secret            ${KEEPASS_DATABASE}     ${KEEPASS_KEY}  ${KEEPASS_GOD_KEY_ENTRY}            username
    ${god_secret}           Load Keepass Database Secret            ${KEEPASS_DATABASE}     ${KEEPASS_KEY}  ${KEEPASS_GOD_KEY_ENTRY}            password
    ${god_name}             Load Keepass Database Secret            ${KEEPASS_DATABASE}     ${KEEPASS_KEY}  ${KEEPASS_GOD_USERNAME}     username
    ${ACCOUNT}              Load Keepass Database Secret            ${KEEPASS_DATABASE}     ${KEEPASS_KEY}  ${KEEPASS_ACCOUNT_ENTRY}            password
    Initialize Terraform    ${REGION}   ${god_access}   ${god_secret}
    Initialize S3           None        ${god_access}   ${god_secret}    ${REGION}
    ${TF_PARAMETERS}=       Create Dictionary   account=${ACCOUNT}    service_principal=${god_name}
    Set Global Variable     ${TF_PARAMETERS}
    Set Global Variable     ${ACCOUNT}


Create Multiple Buckets
    [Documentation]         Create Buckets And Check That The AWS Infrastructure Match Specifications
    Launch Terraform Deployment                 ${CURDIR}/../data/multiple  ${TF_PARAMETERS}
    ${states}   Load Terraform States           ${CURDIR}/../data/multiple
    ${specs}    Load Multiple Test Data         ${states['test']['outputs']['s3']['value']}   ${states['test']['outputs']['logging']['value']}  ${REGION}
    Buckets Shall Exist And Match               ${specs['buckets']}     ${ACCOUNT}
    [Teardown]  Destroy Terraform Deployment    ${CURDIR}/../data/multiple  ${TF_PARAMETERS}
