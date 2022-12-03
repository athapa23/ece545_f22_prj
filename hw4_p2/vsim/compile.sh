#!/bin/tcsh -f

./clean.sh
mkdir logs

# Create the source file lists
rm -f ./hdl_files.txt
touch ./hdl_files.txt
foreach i ( hdl_reuse_files.txt hdl_src_files.txt hdl_tb_files.txt )
   if ( -e ./${i} ) then
      cat ./${i} >> ./hdl_files.txt
   endif
end

# Compile each source
set EXTRA_OPTS_COMPILE=''
if ( -e ./extra_opts_compile.txt ) then
   set EXTRA_OPTS_COMPILE=`cat extra_opts_compile.txt`
endif

vlib work
vcom -2008 -F hdl_files.txt $EXTRA_OPTS_COMPILE -endlib -l ./logs/compile.log
# additional libs and file lists can be chained on here
# however, better to add them in extra_opts_compile.txt so no 
# need to update the script