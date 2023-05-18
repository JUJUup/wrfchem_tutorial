#!/bin/csh
#BSUB -J WRF_tutorial
#BSUB -q amd_milan
#BSUB -n 128
#BSUB -o wrf.out
#BSUB -e wrf.err
##BSUB -W 360:00

# --------------------------------------
# Define some variables and directories
# --------------------------------------
# In most case, you only need to change this part.
set WORKDIR = /share/home/lililei4/haoxing/wrfv4_tutorial/wrf_exptfield/wrfchem_rundir/ # where things running.

set WRF_DIR = /share/home/lililei4/haoxing/wrfv4_tutorial/WRF-4.3.3/ # WPS top dir #$%^ change this if needed.
set NAMELIST_DIR = /share/home/lililei4/haoxing/wrfv4_tutorial/wrf_exptfield/namelist_template # where you store your namelist.
set EMISS_DIR = /share/home/lililei4/haoxing/wrfv4_tutorial/ANTHRO/src # where you store your emission files. in this case, emission should be in ANTRO/src

set run_chem = true # run chem or only wrf? #$%^ change this if needed.

# ----------------
# run WRF.
# ----------------
cd $WORKDIR
ln -sf ${WRF_DIR}/run/* .
rm namelist.input # rm the template namelist.input in ${WRF_DIR}/run/
if ($run_chem == true ) then
    cp $NAMELIST_DIR/namelist_chem.input ./namelist.input #$%^ change this if needed
else 
    cp $NAMELIST_DIR/namelist_infa.input ./namelist.input #$%^ change this if needed
endif

if ($run_chem == true ) then ln -sf $EMISS_DIR/wrfchemi* . # link EMISSION file

mpirun ./wrf.exe

mv rsl.error.0000 rsl_err_SAVE_wrf
rm rsl.*