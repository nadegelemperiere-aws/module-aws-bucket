# -------------------------------------------------------
# TECHNOGIX
# -------------------------------------------------------
# Copyright (c) [2022] Technogix SARL
# All rights reserved
# -------------------------------------------------------
# Module to deploy an aws s3 bucket with all the secure
# components required
# -------------------------------------------------------
# Nadège LEMPERIERE, @12 november 2021
# Latest revision: 12 november 2021
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

output "website_endpoint" {
    value = aws_s3_bucket.bucket.website_endpoint
}

output "website_domain" {
    value = aws_s3_bucket.bucket.website_domain
}
