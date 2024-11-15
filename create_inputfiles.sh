#!/bin/bash

. config


# We need fallocate. It's the fastest way to create files.
if command -v fallocate >/dev/null 2>&1; then
    echo "ERROR: fallocate is not available." 1>&2
fi


echo "Creates a pool of files for read tests."
echo
echo "File size" "$FILESIZE" "is loaded from the 'config' file."
echo
echo "The recommended pool size is 10 times available RAM."
MEM_AVAILABLE=$(awk '/MemAvailable/ {print $2 * 1024}' /proc/meminfo)
nfiles=$(( 10 * MEM_AVAILABLE / FILESIZE ))
echo "On this system, that would be" "$nfiles" "files."
echo
echo "Creating files in $READDIR ..."
echo

mkdir -p "$READDIR"

for ((i = 1; i <= nfiles; i++)); do
    fallocate -l "$FILESIZE" "$READDIR/file$i" &
    if (( i % 10 == 0 )) ; then
        wait  # Wait every 10 files to avoid overwhelming the system
    fi
done
wait

echo "Done."
