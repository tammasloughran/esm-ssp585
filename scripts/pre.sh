#!/bin/bash
set -eu

pwd

# Update land use field to be correct for the current date in the current restart file

./scripts/update_landuse.py work/atmosphere/restart_dump.astart
