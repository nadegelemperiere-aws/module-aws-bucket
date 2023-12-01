# -------------------------------------------------------
# Copyright (c) [2022] Nadege Lemperiere
# All rights reserved
# -------------------------------------------------------
# Module to deploy an aws s3 bucket with all the secure
# components required
# -------------------------------------------------------
# Nadège LEMPERIERE, @12 november 2021
# Latest revision: 19 november 2023
# -------------------------------------------------------

# -------------------------------------------------------
# Contact e-mail for this deployment
# -------------------------------------------------------
variable "email" {
	type 	= string
	nullable = false
}

# -------------------------------------------------------
# Environment for this deployment (prod, preprod, ...)
# -------------------------------------------------------
variable "environment" {
	type 	= string
	nullable = false
}
variable "region" {
	type 	= string
	nullable = false
}

# -------------------------------------------------------
# Topic context for this deployment
# -------------------------------------------------------
variable "project" {
	type    = string
	nullable = false
}
variable "module" {
	type 	= string
	nullable = false
}

# -------------------------------------------------------
# Solution version
# -------------------------------------------------------
variable "git_version" {
	type    = string
	default = "unmanaged"
	nullable = false
}

# -------------------------------------------------------
# Bucket name
# -------------------------------------------------------
variable "name" {
	type = string
	nullable = false
}

# -------------------------------------------------------
# Access logging bucket identifier is any
# -------------------------------------------------------
variable "shall_log_access" {
	type = bool
	default = false
	nullable = false
}
variable "logging_bucket" {
	type = string
	default = null
}

# -------------------------------------------------------
# S3 bucket lifecycle rules
# -------------------------------------------------------
variable "lifecycles" {
	type = list(object({
		identifier 	= string
		prefix 		= string
		transitions = optional(list(object({
			days 			= string,
			storage_class 	= string
		})))
		expiration = optional(object({
			days 			= string
		}))
		noncurrent_version_transitions = optional(list(object({
			days 			= string,
			number 			= string,
			storage_class 	= string
		})))
		noncurrent_version_expiration = optional(object({
			days 			= string,
			number 			= string
		}))
	}))
	default = null
}
variable "lock" {
	type = number
	nullable = false
	default = 5
}


# --------------------------------------------------------
# S3 bucket access rights + Service principal and account
# to ensure root and service principal can access
# --------------------------------------------------------
variable "rights" {
	type = list(object({
		description = string,
		actions 	= list(string)
		principal 	= object({
			aws 		= optional(list(string))
			services 	= optional(list(string))
		}),
		content 	= bool
	}))
	default = null
}
variable "service_principal" {
	type = string
	nullable = false
}
variable "account" {
	type = string
	nullable = false
}

# --------------------------------------------------------
# Remove bucket public access
# --------------------------------------------------------
variable "private" {
	type 	= bool
	default = true
	nullable = false
}