#!/bin/bash

# Initialise an ACCESS-ESM Payu run from a CSIRO experiment
set -eu

# Start year of this run - should match config.yaml & the model namelists
start_year=1850

# CSIRO job to copy the warm start from
project=p66
user=cm2704
expname=PI-01
source_year=541

export csiro_source=/g/data/$project/$user/archive/$expname/restart

scripts/warm-start-csiro.sh
