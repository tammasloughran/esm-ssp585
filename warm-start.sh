#!/bin/bash

# Initialise an ACCESS-ESM Payu run from a CSIRO experiment
set -eu

module load nco

start_year=1850

project=p66
user=cm2704
expname=PI-01
source_year=541

csiro_source=/g/data/$project/$user/archive/$expname/restart

payu sweep > /dev/null
payu setup --archive
payu_archive=./archive

payu_restart=${payu_archive}/restart000

if [ -d ${payu_restart} ]; then
    echo "ERROR: Restart directory already exists"
    echo "Consider 'payu sweep --hard' to delete all restarts"
    exit 1
fi

mkdir $payu_restart
mkdir $payu_restart/{atmosphere,ocean,ice,coupler}

yearstart="$(printf '%04d' $source_year)0101"
pyearend="$(printf '%04d' $(( source_year - 1 )) )1231"

cp -v $csiro_source/atm/${expname}.astart-${yearstart} $payu_restart/atmosphere/restart_dump.astart

for f in $csiro_source/cpl/*-${pyearend}; do
    cp -v $f $payu_restart/coupler/$(basename ${f%-*})
done

for f in $csiro_source/ocn/*-${pyearend}; do
    cp -v $f $payu_restart/ocean/$(basename ${f%-*})
done

for f in $csiro_source/ice/*-${pyearend}; do
    cp -v $f $payu_restart/ice/$(basename ${f%-*})
done
cp -v $csiro_source/ice/iced.${yearstart} $payu_restart/ice/

# Update ocean start time
cat > $payu_restart/ocean/ocean_solo.res << EOF
    3
    1 1 1 0 0 0
    $start_year 1 1 0 0 0
EOF

# Update atmos start time
python scripts/update_um_year.py $start_year $payu_restart/atmosphere/restart_dump.astart > /dev/null

# Update ice start time
cat > $payu_restart/ice/cice_in.nml << EOF
&setup_nml
istep0=0,
npt=0,
dt=3600,
/
EOF

cat > $payu_restart/ice/input_ice.nml << EOF
&coupling
runtime0=0
runtime=0
/
EOF

ncatted -a units,time,o,c,"seconds since ${start_year}-01-01 00:00:00" $payu_restart/ice/mice.nc

secs_realyr=$(python -c "from datetime import date; d=(date(1850,1,1)-date(1,1,1)); print(d.days*24*60*60)")
~access/data/ACCESS_CMIP5/utils/cicedumpdatemodify.py -i $payu_restart/ice/iced.${yearstart} -o $payu_restart/ice/iced.${start_year} --istep0=0 --time=${secs_realyr}. --time_forc=0.
cat > $payu_restart/ice/ice.restart_file << EOF
iced.${start_year}
EOF

payu sweep
