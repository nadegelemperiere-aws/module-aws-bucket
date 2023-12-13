# -------------------------------------------------------
# Copyright (c) [2022] Nadege Lemperiere
# All rights reserved
# -------------------------------------------------------
# Module to deploy an aws s3 bucket with all the secure
# components required
# -------------------------------------------------------
# Nadège LEMPERIERE, @12 november 2021
# Latest revision: 13 december 2023
# ------------------------------------------------------

output "id" {
    value = aws_s3_bucket.bucket.id
}

output "arn" {
    value = aws_s3_bucket.bucket.arn
}

output "region" {
    value = aws_s3_bucket.bucket.region
}

output "domain" {
    value = aws_s3_bucket.bucket.bucket_domain_name
}

output "region_domain" {
    value = aws_s3_bucket.bucket.bucket_regional_domain_name
}

output "zone" {
    value = aws_s3_bucket.bucket.hosted_zone_id
}

output "key" {
    value = aws_kms_key.bucket.arn
}