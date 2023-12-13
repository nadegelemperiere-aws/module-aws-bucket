# -------------------------------------------------------
# Copyright (c) [2022] Nadege Lemperiere
# All rights reserved
# -------------------------------------------------------
# Simple deployment for testing
# -------------------------------------------------------
# Nadège LEMPERIERE, @12 november 2021
# Latest revision: 13 december 2023
# -------------------------------------------------------


# -------------------------------------------------------
# Local test variables
# -------------------------------------------------------
locals {
	test_buckets = [
		{ 	name = "test-1", logging_bucket = aws_s3_bucket.logging.id, shall_log = true},
		{ 	name = "test-2", private = false											},
		{	name = "test-3", lifecycles = [{identifier = "test-3", prefix = "test-3", expiration = { days = 2}}]},
		{	name = "test-4", lifecycles = [{identifier = "test-4", prefix = "test-4", transitions = [
					{ days = 30, storage_class = "STANDARD_IA"},
					{ days = 60, storage_class = "GLACIER"}
				],
				expiration = { days = 90}
			}]
		},
		{	name = "test-5", lifecycles = [{identifier = "test-5", prefix = "test-5", transitions = [
					{ days = 30, storage_class = "STANDARD_IA"},
					{ days = 60, storage_class = "GLACIER"}
				],
				expiration = { days = 90}
			}],
			rights = [
				{ description = "AllowLoggingService", actions = ["s3:PutObject"], principal = { services = ["delivery.logs.amazonaws.com"]}, content = true }
			],
			lock = 7
		}
	]
}

# -------------------------------------------------------
# Create the s3 bucket
# -------------------------------------------------------
resource "random_string" "random" {
	length		= 32
	special		= false
	upper 		= false
}
resource "aws_s3_bucket" "logging" {
	bucket = random_string.random.result
}

# -------------------------------------------------------
# Create bucket using the current module
# -------------------------------------------------------
module "buckets" {

	count 				= length(local.test_buckets)

	source 				= "../../../"
	email 				= "moi.moi@moi.fr"
	project 			= "test"
	environment 		= "test"
	region				= var.region
	module 				= "test"
	git_version 		= "test"
	service_principal 	= var.service_principal
	account				= var.account
	name 				= "${local.test_buckets[count.index].name}"
	lock 				= lookup("${local.test_buckets[count.index]}", "lock", null)
	shall_log_access    = lookup("${local.test_buckets[count.index]}", "shall_log", false)
	logging_bucket 		= lookup("${local.test_buckets[count.index]}", "logging_bucket", null)
	lifecycles			= lookup("${local.test_buckets[count.index]}", "lifecycles", null)
	rights				= lookup("${local.test_buckets[count.index]}", "rights", null)
	private				= lookup("${local.test_buckets[count.index]}", "private", true)
}

# -------------------------------------------------------
# Terraform configuration
# -------------------------------------------------------
provider "aws" {
	region		= var.region
	access_key 	= var.access_key
	secret_key	= var.secret_key
}

terraform {
	required_version = ">=1.6.4"
	backend "local"	{
		path="terraform.tfstate"
	}
}

# -------------------------------------------------------
# Region for this deployment
# -------------------------------------------------------
variable "region" {
	type    = string
}

# -------------------------------------------------------
# AWS credentials
# -------------------------------------------------------
variable "access_key" {
	type    	= string
	sensitive 	= true
}
variable "secret_key" {
	type    	= string
	sensitive 	= true
}

# -------------------------------------------------------
# IAM account which root to use to test access rights settings
# -------------------------------------------------------
variable "account" {
	type 		= string
	sensitive 	= true
}
variable "service_principal" {
	type 		= string
	sensitive 	= true
}

# -------------------------------------------------------
# Test outputs
# -------------------------------------------------------
output "s3" {
	value = {
		ids 		= module.buckets.*.id
		arns 		= module.buckets.*.arn
		regions 	= module.buckets.*.region
		domains 	= module.buckets.*.domain
		rdomains 	= module.buckets.*.region_domain
		zones		= module.buckets.*.zone
	}
}

output "logging" {
	value = aws_s3_bucket.logging.id
}
