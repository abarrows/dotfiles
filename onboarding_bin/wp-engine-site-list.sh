#!/bin/bash

# TODO: Use git.repo.name and string hyphens and underscores then limit to 14 (which is the current limit)
# TODO: Daily Cartoonist copy over to daily cartoon as the environment name
# TODO: Kill any sites that are no longer used.
# TODO: Kill all environment sites
# TODO: R&D - If there is a site metadata best practice or standard to store this repo url.
# COMPLETE: Use api https://wpengineapi.com/ to get list of sites
# TODO: Add API request: https://api.wpengineapi.com/v1/sites and check for:
#   1. Foreach installs do
#        1. "environment": ENV["environment"] || "production"
#        2. Return this.name
# INFO: Environment is permanent and (Think of JIRA Project Key)
# INFO: To delete a site, admin has to do it.
#   1. INFO: API access is in ACB swagger
