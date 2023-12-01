# -------------------------------------------------------
# Copyright (c) [2022] Nadege Lemperiere
# All rights reserved
# -------------------------------------------------------
# Module to deploy an aws s3 bucket with all the secure
# components required
# -------------------------------------------------------
# Nadège LEMPERIERE, @26 november 2021
# Latest revision: 26 november 2021
# -------------------------------------------------------

# -------------------------------------------------------
# Create the s3 bucket
# -------------------------------------------------------
resource "aws_s3_bucket" "bucket" {

	bucket = "${var.project}-${var.environment}-${var.region}-${var.name}"

	object_lock_enabled = true

  	tags = {
		Name           	= "${var.project}.${var.environment}.${var.module}.${var.region}.${var.name}.s3"
		Environment     = var.environment
		Owner   		= var.email
		Project   		= var.project
		Version 		= var.git_version
		Module  		= var.module
	}
}

# -------------------------------------------------------
# Create the s3 bucket lock configuration
# -------------------------------------------------------
resource "aws_s3_bucket_object_lock_configuration" "bucket" {

	bucket = aws_s3_bucket.bucket.id

  	rule {
    	default_retention {
     		mode = "COMPLIANCE"
      		days = var.lock
    	}
  	}
}

# -------------------------------------------------------
# Enable versioning
# -------------------------------------------------------
resource "aws_s3_bucket_versioning" "bucket" {

	bucket = aws_s3_bucket.bucket.id
  	versioning_configuration {
   		status = "Enabled"
  	}
}

# -------------------------------------------------------
# Define encryption rules
# -------------------------------------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {

	bucket = aws_s3_bucket.bucket.id

  	rule {
		apply_server_side_encryption_by_default {
			kms_master_key_id 	= aws_kms_key.bucket.arn
			sse_algorithm     	= "aws:kms"
		}
		bucket_key_enabled 		= true
	}

}

# -------------------------------------------------------
# Define lifecycle
# -------------------------------------------------------
resource "aws_s3_bucket_lifecycle_configuration" "bucket" {

	count = ((var.lifecycles == null) ? 0 : 1)

  	bucket = aws_s3_bucket.bucket.id

	dynamic "rule" {

		for_each = ((var.lifecycles != null) ? var.lifecycles : [])
		content {

			id      = rule.value.identifier
			prefix  = rule.value.prefix
			status = "Enabled"

			dynamic "transition" {
				for_each = ((rule.value.transitions != null) ? rule.value.transitions : [])
				content {
					days           = transition.value.days
					storage_class  = transition.value.storage_class
				}
			}

			dynamic "expiration" {
				for_each = ((rule.value.expiration != null) ? [rule.value.expiration] : [])
				content {
					days 	       = expiration.value.days
				}
			}

			dynamic "noncurrent_version_transition" {
				for_each = ((rule.value.noncurrent_version_transitions != null) ? rule.value.noncurrent_version_transitions : [])
				content {
					noncurrent_days 		  = noncurrent_version_transition.value.days
					newer_noncurrent_versions = noncurrent_version_transition.value.number
					storage_class 			  = noncurrent_version_transition.value.storage_class
				}
			}

			dynamic "noncurrent_version_expiration" {
				for_each = ((rule.value.noncurrent_version_expiration != null) ? [rule.value.noncurrent_version_expiration] : [])
				content {
					noncurrent_days 		  = noncurrent_version_expiration.value.days
					newer_noncurrent_versions = noncurrent_version_expiration.value.number
				}
			}
		}
  	}
}

# -------------------------------------------------------
# Define access logging
# -------------------------------------------------------
resource "aws_s3_bucket_logging" "bucket" {

	count = (var.shall_log_access ? 1 : 0)

	bucket = aws_s3_bucket.bucket.id

	target_bucket = var.logging_bucket
	target_prefix = "access/"

}

# -------------------------------------------------------
# Set permission policy for s3 bucket access
# -------------------------------------------------------
locals {
	kms_statements = concat([
		for i,right in ((var.rights != null) ? var.rights : []) :
		{
			Sid 		= right.description
			Effect 		= "Allow"
			Principal 	= {
				"AWS" 		: ((right.principal.aws != null) ? right.principal.aws : [])
				"Service" 	: ((right.principal.services != null) ? right.principal.services : [])
			}
			Action 		= ["kms:Decrypt","kms:GenerateDataKey"],
			Resource	= ["*"]
		}
	],
	[
		{
			Sid 		= "AllowRootAndServicePrincipal"
			Effect 		= "Allow"
			Principal 	= {
				"AWS" 		: ["arn:aws:iam::${var.account}:root", "arn:aws:iam::${var.account}:user/${var.service_principal}"]
			}
			Action 		= "kms:*",
			Resource	= ["*"]
		}
	])
}

# -------------------------------------------------------
# Bucket encryption key
# -------------------------------------------------------
resource "aws_kms_key" "bucket" {

	description             	= "Bucket ${var.name} encryption key"
	key_usage					= "ENCRYPT_DECRYPT"
	customer_master_key_spec	= "SYMMETRIC_DEFAULT"
	deletion_window_in_days		= 7
	enable_key_rotation			= true
  	policy						= jsonencode({
  		Version = "2012-10-17",
  		Statement = local.kms_statements
	})

	tags = {
		Name           	= "${var.project}.${var.environment}.${var.module}.${var.region}.${var.name}.s3.key"
		Environment     = var.environment
		Owner   		= var.email
		Project   		= var.project
		Version 		= var.git_version
		Module  		= var.module
	}
}

# -------------------------------------------------------
# Set permission policy for s3 bucket access
# -------------------------------------------------------
locals {
	s3_statements = concat([
		for i,right in ((var.rights != null) ? var.rights : []) :
		{
			Sid 		= right.description
			Effect 		= "Allow"
			Principal 	= {
				"AWS" 		: ((right.principal.aws != null) ? right.principal.aws : [])
				"Service" 	: ((right.principal.services != null) ? right.principal.services : [])
			}
			Action 		= right.actions
			Resource 	= (right.content ? "${aws_s3_bucket.bucket.arn}/*" : aws_s3_bucket.bucket.arn)
		}
	],
	[
		{
			Sid 		= "AllowRootAndServicePrincipal"
			Effect 		= "Allow"
			Principal 	= {
				"AWS" 		: ["arn:aws:iam::${var.account}:root", "arn:aws:iam::${var.account}:user/${var.service_principal}"]
			}
			Action 		= "s3:*"
			Resource 	= ["${aws_s3_bucket.bucket.arn}/*",aws_s3_bucket.bucket.arn]
		},
        {
			Sid 		 = "AllowSSLRequestsOnly"
			Effect 		 = "Deny"
			Action 		 = "s3:*"
            NotPrincipal = {
				"Service" : [ "cloudtrail.amazonaws.com", "delivery.logs.amazonaws.com", "s3.amazonaws.com", "config.amazonaws.com"]
			}
			Resource 	 = ["${aws_s3_bucket.bucket.arn}/*",aws_s3_bucket.bucket.arn]
            Condition    = {
                "Bool" : { "aws:SecureTransport": "false" }
            }
		},
		{
			Sid 		 = "DenyUnEncryptedObjectUploads"
			Effect 		 = "Deny"
			Action 		 = "s3:PutObject"
            NotPrincipal = {
				"Service" : [ "cloudtrail.amazonaws.com", "delivery.logs.amazonaws.com", "s3.amazonaws.com", "config.amazonaws.com"]
			}
			Resource 	 = ["${aws_s3_bucket.bucket.arn}/*"]
            Condition    = {
                "Null":{ "s3:x-amz-server-side-encryption":"true" }
            }
		}
	])
}

# -------------------------------------------------------
# Allow writing in s3 bucket for dedicated users and/or
# services
# -------------------------------------------------------
resource "aws_s3_bucket_policy" "bucket" {

	bucket = aws_s3_bucket.bucket.id

  	policy = jsonencode({
    	Version = "2012-10-17"
		Statement = local.s3_statements
	})
}


# -------------------------------------------------------
# Manage object owners in bucket
# -------------------------------------------------------
resource "aws_s3_bucket_ownership_controls" "bucket" {

	bucket = aws_s3_bucket.bucket.id

  	rule {
    	object_ownership = "BucketOwnerPreferred"
  	}
}

# -------------------------------------------------------
# Block s3 bucket public access
# -------------------------------------------------------
resource "aws_s3_bucket_public_access_block" "bucket" {

	count 					= var.private ? 1 : 0
	depends_on 				= [ aws_s3_bucket_policy.bucket ]

    bucket                  = aws_s3_bucket.bucket.id
    block_public_acls       = true
    ignore_public_acls      = true
    block_public_policy     = true
    restrict_public_buckets = true
}
