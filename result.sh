#!/bin/bash

usage () {
  echo "Read results of the dd performance test."
  echo "Usage:  ./result.sh [--skip number]"
  echo "    --skip n: skip the first n measurements (because they might be inaccurate)"
  echo "    --tail n: process only the last n measurements"
  exit 1
}

. config

total_mibps_read=0
total_mibps_write=0
verbose=false
# By default, we want to process all records
tailspec='+1'

# Process arguments
while [ $# -gt 0 ] ; do
  case "$1" in
    -h | --help )
      usage
      ;;
    --skip )
      tailspec="+$(( $2 + 1 ))"
      shift ; shift
      ;;
    --tail )
      if [ "$2" -lt 10 ] ; then
        echo "WARNING: processing fewer than 10 copy actions may give inaccurate results."
      fi
      tailspec="$2"
      shift ; shift
      ;;
    --verbose )
      verbose=true
      shift
      ;;
    * )
      echo "ERROR: illegal argument '$1'"
      usage
      ;;
  esac
done


running_dd=$(pgrep '^dd' | wc -l)
echo "Running dd tests: $running_dd"
echo

shopt -s nullglob  # Enable nullglob to avoid errors when no matches

for file in ioread* ; do
  mibps=$(grep 'bytes \(.*\) copied' "$file" \
          | tail -n "$tailspec" \
          | awk 'BEGIN { sum = 0; sec = 0 }
                 { sum += $1; sec += $8 }
                 END {
                       if (sec == 0) {
                         printf "%.2f\n", 0;
                       } else {
                         printf "%.2f\n", sum / sec / 1024 / 1024;
                       }
                     }'
         )
  if $verbose ; then
    echo "$file : $mibps"
  fi
  total_mibps_read=$(awk "BEGIN {print $total_mibps_read + $mibps}")
done


for file in iowrite* ; do
  mibps=$(grep 'bytes \(.*\) copied' "$file" \
          | tail -n "$tailspec" \
          | awk 'BEGIN { sum = 0; sec = 0 }
                 { sum += $1; sec += $8 }
                 END {
                       if (sec == 0) {
                         printf "%.2f\n", 0;
                       } else {
                         printf "%.2f\n", sum / sec / 1024 / 1024;
                       }
                     }'
         )
  if $verbose ; then
    echo "$file : $mibps"
  fi
  total_mibps_write=$(awk "BEGIN {print $total_mibps_write + $mibps}")
done

if $verbose ; then
  echo
fi


echo "Total READ  : $total_mibps_read MiB/s"
echo "Total WRITE : $total_mibps_write MiB/s"

grand_total=$(awk "BEGIN {print $total_mibps_read + $total_mibps_write}")
echo "Grand total : $grand_total MiB/s"
