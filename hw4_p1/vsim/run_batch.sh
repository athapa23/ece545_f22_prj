#!/bin/tcsh -f

set TEST_NAME="test_default"
if ( -e ./test_list.txt ) then
   if ( $# == 0 || `grep -cve '^\s*$' tb_entity.txt` != 1) then
      echo "Usage: run_batch.sh [test_name]"
      echo "Available tests:"
      cat ./test_list.txt
      exit(1)
   else
      set TEST_NAME=`echo ${1} | sed 's/:/_/g'`
   endif
endif

mkdir -p logs

rm -f ./hdl_files.txt
touch ./hdl_files.txt

foreach i ( hdl_reuse_files.txt hdl_src_files.txt hdl_tb_files.txt )
   if ( -e ./${i} ) then
      cat ./${i} >> ./hdl_files.txt
   endif
end

set SEED1_GEN=`od -An -N2 -tu2 /dev/urandom`
set SEED2_GEN=`od -An -N2 -tu2 /dev/urandom`

# Create a waiver string
set CVG_EXCLUSION=''
if ( -e ./cvg_exclusion.txt ) then
   set CVG_EXCLUSION=`cat cvg_exclusion.txt`
endif

if ( -e ./tb_entity.txt ) then
   set CELL_VIEW=`head -n 1 ./tb_entity.txt`
   vsim -voptargs="+acc" work.${CELL_VIEW} -c \
   -g TEST_NAME=${TEST_NAME} \
   -g SEED1_GEN=${SEED1_GEN} -g SEED2_GEN=${SEED2_GEN} \
   -l transcript_${TEST_NAME}.txt \
   -do "coverage save -onexit ${TEST_NAME}.ucdb;$CVG_EXCLUSION;run -all;exit" \
   -coverage -voptargs=+cover=bcefs
endif

exit($status)   

