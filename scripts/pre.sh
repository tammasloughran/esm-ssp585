#!/bin/bash

source  /etc/profile.d/modules.sh
module use /g/data/hh5/public/modules
module load conda/analysis3

set -eu
pwd
ls work

lu_file=$1

# Update land use field to be correct for the current date in the current restart file
year=$(mule-pumf --component fixed_length_header work/atmosphere/restart_dump.astart | sed -n 's/.*t2_year\s*:\s*//p')

if cdo selyear,$(( year )) -chname,fraction,field1391 $lu_file work/atmosphere/land_frac.nc; then

    mv work/atmosphere/restart_dump.astart work/atmosphere/restart_dump.astart.orig
    python scripts/update_cable_vegfrac.py -i work/atmosphere/restart_dump.astart.orig -o work/atmosphere/restart_dump.astart -f work/atmosphere/land_frac.nc
fi
