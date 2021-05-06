#!/bin/bash

# Initialise an ACCESS-ESM Payu run from a CSIRO experiment
#
# This script sets values specific to the experiment, it then calls the common
# 'warm-start' from the scripts directory
set -eu

# Start year of this run - should match config.yaml & the model namelists
start_year=1850

# CSIRO job to copy the warm start from
project=p66
user=cm2704
export expname=PI-01            # Source experiment - PI pre-industrial, HI historical
export source_year=541          # Change this to create different ensemble members
export csiro_source=/g/data/$project/$user/archive/$expname/restart

# Call the main warm-start script
scripts/warm-start-csiro.sh
