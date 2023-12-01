# -------------------------------------------------------
# Copyright (c) [2022] Nadege Lemperiere
# All rights reserved
# -------------------------------------------------------
# Module to deploy an aws s3 bucket with all the secure
# components required
# -------------------------------------------------------
# Nadège LEMPERIERE, @19 november 2023
# Latest revision: 19 november 2023
# ------------------------------------------------------

terraform {
  required_version = ">= 1.6.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.29.0"
    }
  }
}