#!/bin/bash

OF=/dev/null

. config

MiB=1048576

size=$(stat --format=%s "$READDIR/file1")
size_MiB=$(awk "BEGIN { print $size / 1048576 }")

if [ -z "$size_MiB" ] ; then
  echo "WARNING: could not get file size of the inputfiles."
  exit 1
fi

trap 'exit 0;' INT
trap 'exit 0;' TERM

i=0
while true
do
  ((i++))

  # Pick a random file from the inputfiles directory
  random_file=$(find "$READDIR/" -type f | shuf -n 1)

  echo "read $i: dd if=$random_file of=$OF bs=$BS"
  start=$(date +%s.%N)
  dd if="$random_file" of="$OF" bs="$BS"
  end=$(date +%s.%N)
  seconds=$(awk "BEGIN {print $end - $start}")
  rate=$(awk "BEGIN {print $size_MiB / $seconds}")
  echo "read ${i}: $size bytes copied in $seconds seconds, $rate MiB/s"

done
