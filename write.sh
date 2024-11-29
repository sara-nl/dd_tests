#!/bin/bash

. config

WRITEDIR="${WRITEDIR}/testdir.$$"
IF=/dev/zero
#IF=/dev/urandom

COUNT=$(( FILESIZE / BS ))

trap 'exit 0;' INT
trap 'exit 0;' TERM

mkdir -p "$WRITEDIR"

#MiB=1048576
size_MiB=$(awk "BEGIN {print $FILESIZE / 1048576}")

i=0
while true
do
  ((i++))

  c=$(uuidgen)

  echo "write $i: dd if=$IF of=$WRITEDIR/file$c bs=$BS count=$COUNT"
  start=$(date +%s.%N)
  dd if="$IF" of="$WRITEDIR/file$c" bs="$BS" count="$COUNT"
  end=$(date +%s.%N)
  seconds=$(awk "BEGIN {print $end - $start}")
  rate=$(awk "BEGIN {print $size_MiB / $seconds}")
  echo "write ${i}: $size bytes copied in $seconds seconds, $rate MiB/s"

  # Prevent partition from filling up
  # When disk is >90% full, clean up files older than 1 hour
  # Only check every 1000th file.
  if (( i % 1000 == 0 )) ; then
    # Only start a find when there is no other find running
    if ! pgrep find ; then
      find "$WRITEDIR" -name 'file*' -type f -mmin +60 -delete &
    fi
  fi

done
