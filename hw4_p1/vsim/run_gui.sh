#!/bin/tcsh -f

set TEST_NAME="test_default"
if ( -e ./test_list.txt ) then
   if ( $# == 0 || `grep -cve '^\s*$' tb_entity.txt` != 1) then
      echo "Usage: run_batch.sh [test_name] "
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

if ( -e ./tb_entity.txt ) then
   set CELL_VIEW=`head -n 1 ./tb_entity.txt`
   vsim -voptargs="+acc" work.${CELL_VIEW} \
   -g TEST_NAME=${TEST_NAME} \
   -do "waves.do"
endif

exit($status)