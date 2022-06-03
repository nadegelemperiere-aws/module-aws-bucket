# -------------------------------------------------------
# TECHNOGIX
# -------------------------------------------------------
# Copyright (c) [2022] Technogix SARL
# All rights reserved
# -------------------------------------------------------
# Keywords to create data for module test
# -------------------------------------------------------
# Nadège LEMPERIERE, @13 november 2021
# Latest revision: 13 november 2021
# -------------------------------------------------------

# System includes
from json import load, dumps

# Robotframework includes
from robot.libraries.BuiltIn import BuiltIn, _Misc
from robot.api import logger as logger
from robot.api.deco import keyword
ROBOT = False

# ip address manipulation
from ipaddress import IPv4Network

@keyword('Load Multiple Test Data')
def load_multiple_test_data(buckets, logging, region) :

    result = {}
    result['buckets'] = []

    if len(buckets['ids']) != 5 : raise Exception(str(len(buckets['ids'])) + ' buckets created instead of 5')

    for i in range(1,6) :
        bucket = {}
        bucket['Name'] = 'test-test-' + region + '-test-' + str(i)

        bucket['ServerSideEncryptionConfiguration'] = {}
        bucket['ServerSideEncryptionConfiguration']['Rules'] = []
        bucket['ServerSideEncryptionConfiguration']['Rules'].append(
            {"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "aws:kms"}, "BucketKeyEnabled": True})

        bucket['Tags'] = []
        bucket['Tags'].append({'Key'        : 'Version'             , 'Value' : 'test'})
        bucket['Tags'].append({'Key'        : 'Project'             , 'Value' : 'test'})
        bucket['Tags'].append({'Key'        : 'Module'              , 'Value' : 'test'})
        bucket['Tags'].append({'Key'        : 'Environment'         , 'Value' : 'test'})
        bucket['Tags'].append({'Key'        : 'Owner'               , 'Value' : 'moi.moi@moi.fr'})
        bucket['Tags'].append({'Key'        : 'Name'                , 'Value' : 'test.test.test.' + region + '.test-' + str(i) + '.s3'})

        if i != 2 :
            bucket['PublicAccessBlockConfiguration'] = {
                'BlockPublicAcls': True,
                'IgnorePublicAcls': True,
                'BlockPublicPolicy': True,
                'RestrictPublicBuckets': True}
        else :
            bucket['PublicAccessBlockConfiguration'] = {}

        if i == 1:
            bucket['LoggingEnabled'] = {"TargetBucket": logging, "TargetPrefix": "access/"}

        bucket['Rules'] = []
        if i == 3 : bucket['Rules'].append(
            {'ID' : 'test-3', 'Prefix' : 'test-3', 'Status': 'Enabled' , 'Expiration' : {'Days' : 2}})
        if i == 4 or i == 5 : bucket['Rules'].append(
            {'ID' : 'test-' + str(i), 'Prefix' : 'test-' + str(i), 'Status': 'Enabled',
            'Transitions' : [{'Days' : 30, 'StorageClass' : 'STANDARD_IA'}, {'Days' : 60, 'StorageClass' : 'GLACIER'}],
            'Expiration' : {'Days' : 90}})

        bucket['Policy'] = {"Version":"2012-10-17","Statement":[{"Sid":"DenyUnEncryptedObjectUploads", "Effect":"Deny", "Action":"s3:PutObject","NotPrincipal":{"Service" : [ "cloudtrail.amazonaws.com", "delivery.logs.amazonaws.com", "s3.amazonaws.com", "config.amazonaws.com"]},"Resource":"arn:aws:s3:::test-test-eu-west-1-test-" + str(i) + "/*","Condition":{"Null":{ "s3:x-amz-server-side-encryption":"true" }}},{"Sid":"AllowRootAndServicePrincipal","Effect":"Allow","Principal":{"AWS":["arn:aws:iam::833168553325:user/principal","arn:aws:iam::833168553325:root"]},"Action":"s3:*","Resource":["arn:aws:s3:::test-test-eu-west-1-test-" + str(i) + "/*","arn:aws:s3:::test-test-eu-west-1-test-" + str(i)]},{"Sid": "AllowSSLRequestsOnly", "Effect": "Deny", "NotPrincipal":{"Service" : [ "cloudtrail.amazonaws.com", "delivery.logs.amazonaws.com", "s3.amazonaws.com", "config.amazonaws.com"]}, "Action": "s3:*", "Resource": ["arn:aws:s3:::test-test-eu-west-1-test-" + str(i) + "/*", "arn:aws:s3:::test-test-eu-west-1-test-" + str(i)], "Condition": {"Bool": {"aws:SecureTransport": "false"}}}]}

        if i == 5 :
            bucket['Policy']['Statement'].append({"Sid":"AllowLoggingService","Effect":"Allow","Principal":{"Service":"delivery.logs.amazonaws.com"},"Action":"s3:PutObject","Resource":"arn:aws:s3:::test-test-eu-west-1-test-5/*"})

        result['buckets'].append({'name' : 'test-' + str(i), 'data' : bucket})

    logger.debug(dumps(result))

    return result