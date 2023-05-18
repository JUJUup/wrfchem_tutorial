#!/bin/csh
#-----------------------------------------------------------------------
# Script run_real.csh
#
# Purpose: run real.exe, generating IC/BC for wrf
#
# written by: Haoxing in NJU/Xianlin Campus
#
# Timestamp: 2023-05-16
#-----------------------------------------------------------------------



#$%^ part need change in your case

# --------------------------------------
# Define some variables and directories
# --------------------------------------
# In most case, you only need to change this part.
set WORKDIR = /share/home/lililei4/haoxing/wrfv4_tutorial/wrf_exptfield/wrfchem_rundir/ # where things running. #$%^ change this if needed.
set WPS_OUTPUT_DIR = /share/home/lililei4/haoxing/wrfv4_tutorial/wrf_exptfield/wps_rundir # where you running your WPS. #$%^ change this if needed.

set WRF_DIR = /share/home/lililei4/haoxing/wrfv4_tutorial/WRF-4.3.3/ # WPS top dir #$%^ change this if needed.

set NAMELIST_DIR = /share/home/lililei4/haoxing/wrfv4_tutorial/wrf_exptfield/namelist_template # where you store your namelist. #$%^ change this if needed.

set EMISS_DIR = /share/home/lililei4/haoxing/wrfv4_tutorial/ANTHRO/src # where you store your emission files. in this case, emission should be in ANTRO/src #$%^ change this if needed.

set run_chem = true # run chem or only wrf? #$%^ change this if needed.
# ----------------
# run REAL.
# ----------------
mkdir -p $WORKDIR
cd $WORKDIR

ln -sf ${WRF_DIR}/run/* .
ln -sf ${WPS_OUTPUT_DIR}/met_em* . # link met_em files produced by WPS_OUTPUT_DIR
if ($run_chem == true ) then ln -sf $EMISS_DIR/wrfchemi* . # link EMISSION file
# Haoxing : delete the sed namelist.input part for simplify. you maybe need to notice the namelist setting
if ($run_chem == true ) then
    cp $NAMELIST_DIR/namelist_chem.input ./namelist.input #$%^ change this if needed
else 
    cp $NAMELIST_DIR/namelist_infa.input ./namelist.input #$%^ change this if needed
endif
if ( ! -e ./namelist.input ) then
    echo "Need a namelist.wps in running directory!"
    exit 3
endif

./real.exe

if ( `grep "SUCCESS COMPLETE" rsl.out.0000 | wc -l`  == 0 ) then
    echo "SHIT HAPPENS! Check it out! "
else
    echo "SUCCESS COMPLETE REAL~~~"
    mv rsl.error.0000 rsl_err_SAVE_real
    rm rsl.*
endif

exit 0
