#!/bin/tcsh -f

# Remove if there is an existing covhtml/coverage file
   if (-f merged_coverage.ucdb) then
      rm -rf merged_coverage.ucdb
      rm -rf final_report_*
   endif

# Set Coverage Mode
   if ( $# == 0 ) then
      set GUI="-c"
      set EXIT="exit"
   else
      set GUI=" "
      set EXIT=" "
   endif

# Merge all files $flists into merged_coverage.ucdb
vcover merge -verbose -out merged_coverage.ucdb *.ucdb

# Generate a final text file of the result
vcover report -verbose -output final_report_verbose.txt merged_coverage.ucdb

# Coverage report by File
vsim $GUI -cvgperinstance -viewcov merged_coverage.ucdb -do "coverage report -output final_report_by_srcfile.txt -srcfile=* -code {s b c e f x};$EXIT"

cat final_report_by_srcfile.txt

exit($status)