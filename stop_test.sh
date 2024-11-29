#!/bin/bash
export PATH=/usr/local/bin:$PATH

for expression in '^read.sh' '^write.sh' '^dd' ; do
  echo -n "Searching $expression procs: "
  pgrep "$expression" | wc -l
  echo "Killing..."
  pkill "$expression"
  echo
done

echo "Done."
