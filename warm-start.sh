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

csiro_source=/g/data/$project/$user/archive/$expname/restart

# =====================================================================

# Setup the restart directory
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

# Some restart files are marked jan 01, some are dec 31 of the previous year
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

EOF

# Cleanup
payu sweep
