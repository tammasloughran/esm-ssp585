#!/bin/bash
set -eu

# Update land use field to be correct for the current date in the final restart file output by this run

last_restart=$(ls work/atmosphere/aiihca.d* | tail -n 1)
./scripts/update_landuse.py $last_restart
