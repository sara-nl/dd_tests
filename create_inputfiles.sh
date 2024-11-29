#!/bin/bash

# Creates input files for the read test.
# Optional argument: number of files.
# If no number is specified, this script will create
# a pool of files 10x the available RAM size.

. config

# Config loaded?
if [ -z "$READDIR" ] ; then
    echo "ERROR: var READDIR not set." 1>&2
    exit 1
fi
if [ -z "$FILESIZE" ] ; then
    echo "ERROR: var FILESIZE not set." 1>&2
    exit 1
fi

echo "Creates a pool of files for read tests."
echo
echo "File size" "$FILESIZE" "is loaded from the 'config' file."
echo

if [ -z "$1" ] ; then
  echo "The recommended pool size is 10 times available RAM."
  MEM_AVAILABLE=$(awk '/MemAvailable/ {print $2 * 1024}' /proc/meminfo)
  nfiles=$(( 10 * MEM_AVAILABLE / FILESIZE ))
  echo "On this system, that would be" "$nfiles" "files."
  echo
else
  if [[ $1 =~ ^-?[0-9]+$ ]]; then
    nfiles=$1
  else
    echo "'$1' is not numeric. Please provide a number, or none to let this script decide."
    exit 1
  fi
fi

if [ -d "$READDIR" ] ; then
  echo "Cleaning up dir $READDIR ..."
  rm -f "$READDIR/"file*
  echo
else
  echo "Creating dir $READDIR ..."
  echo
fi

echo "Creating files in $READDIR ..."
echo
mkdir -p "$READDIR"

COUNT=$(awk "BEGIN{print $FILESIZE / $BS}")
for ((i = 1; i <= nfiles; i++)); do
    echo "File nr $i ..."
    # fallocate is blazingly fast, but creates sparse files which are not good for testing.
    #fallocate -l "$FILESIZE" "$READDIR/file$i" &
    dd if=/dev/zero of=$READDIR/file$i bs=$BS count=$COUNT > /dev/null &
    if (( i % 10 == 0 )) ; then
        wait  # Wait every 10 files to avoid overwhelming the system
    fi
done
wait

echo -n "Files in $READDIR : "
ls -1 "$READDIR/"file* | wc -l
du -sh "$READDIR"

echo "Done."
