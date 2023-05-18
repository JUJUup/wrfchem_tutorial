#!/bin/csh -f
#-----------------------------------------------------------------------
# Script run_wps.ksh
#
# Purpose: simply runs WPS
#
# written by: Haoxing in NJU/Xianlin Campus
#
# Timestamp: 2023-05-15
#-----------------------------------------------------------------------

# --------------------------------------
# Define some variables and directories
# --------------------------------------
# In most case, you only need to change this part.
set WORKDIR = /share/home/lililei4/haoxing/wrfv4_tutorial/wrf_exptfield/wps_rundir # where things running.
set GEOGRID_OUTPUT_DIR = ${WORKDIR} # for now, assume GEOGRID_OUTPUT_DIR is just WORKDIR. you can split it in your expt.

set WPS_DIR = /share/home/lililei4/models_wrfchem/WPS-4.0.2 # WPS top dir
set VTABLE_DIR =  ${WPS_DIR}/ungrib/Variable_Tables_2015     #Directory with WPS Vtables

set FNL_DIR = /share/home/lililei4/haoxing/wrfv4_tutorial/wrf_exptfield/fnl_data # where you store your NCAR data

set VTABLE_TYPE = GFS # GFS for most NCAR data (fnl,gfs,etc.)

set NAMELIST_DIR = /share/home/lililei4/haoxing/wrfv4_tutorial/wrf_exptfield/namelist_template # where you store your namelist.

# if you want to know more about GFS/FNL and whats there differents,see here: https://rda.ucar.edu/OS/web/datasets/ds084.1/docs/FNLvGFS.pdf

# ----------------
# run WPS.
# ----------------
mkdir -p $WORKDIR
cd $WORKDIR
# Need a namelist.wps in running directory!
# Haoxing : delete the sed namelist.input part for simplify. you maybe need to notice the namelist setting
# for example: ${opt_metgrid_tbl_path}/{opt_geogrid_tbl_path}, where geogrid/metgrid search for TBL file.
cp $NAMELIST_DIR/namelist.wps ./
# orig namelist.wps may run with ERROR: Mismatch between namelist and input file dimensions.
# need some change 
if ( ! -e ./namelist.wps ) then
    echo "Need a namelist.wps in running directory!"
    exit 3
endif

if ( ! -e ${GEOGRID_OUTPUT_DIR}/geo_em.d01.nc ) then
    ln -sf ${WPS_DIR}/geogrid/geogrid.exe .
    ./geogrid.exe 
    mv ./geogrid.log* $GEOGRID_OUTPUT_DIR
endif

if ( $status != 0 ) then # status == 0 mean everything OK
    echo "ERROR in $0 : geogrid.exe failed! "
    exit $status
endif

# Run ungrib:

ln -sf ${VTABLE_DIR}/Vtable.${VTABLE_TYPE} ./Vtable

rm -f ./GRIBFILE*
${WPS_DIR}/link_grib.csh $FNL_DIR/fnl*
ln -sf ${WPS_DIR}/ungrib/ungrib.exe .
./ungrib.exe

if ( $status != 0 ) then
    echo "ERROR in $0 : ungrib.exe failed! "
    exit $status
endif


# Run metgrid:
ln -sf ${WPS_DIR}/metgrid/metgrid.exe .
./metgrid.exe

if ( $status != 0 ) then
    echo "ERROR in $0 : metgrid.exe failed! "
    exit $status
endif

rm -f ./FILE:*   #remove intermediate files created by ungrib

exit 0