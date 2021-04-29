#!/bin/bash
set -eu

pwd

# Update land use field to be correct for the current date in the current restart file

year=$(mule-pumf --component fixed_length_header work/atmosphere/restart_dump.astart | sed -n 's/.*t2_year\s*:\s*//p')

cdo selyear,$(( year + 1 )) -chname,fraction,field1391 work/atmosphere/INPUT/cableCMIP6_LC_1850-2015.nc work/atmosphere/land_frac.nc
mv work/atmosphere/restart_dump.astart work/atmosphere/restart_dump.astart.orig
python scripts/update_cable_vegfrac.py -i work/atmosphere/restart_dump.astart.orig -o work/atmosphere/restart_dump.astart -f work/atmosphere/land_frac.nc -v
