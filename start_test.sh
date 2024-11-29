#!/bin/bash

usage () {
  {
    echo "Starts a number of parallel read and/or write processes."
    echo
    echo "  ./start_tests.sh"
    echo "      --read <num of procs>"
    echo "      --write <num of procs>"
    echo
    echo "Run create_inputfiles.sh first to prepare."
    exit 1
  } 1>&2
}

# We need some arguments
if [ -z "$1" ]; then
   usage
fi

# Process arguments
while [ $# -gt 0 ] ; do
  case "$1" in
    -h | --help )
      usage
      ;;
    --read )
      num_of_reads=$2
      shift ; shift
      ;;
    --write )
      num_of_writes=$2
      shift ; shift
      ;;
    * )
      echo "ERROR: illegal argument '$1'"
      usage
      ;;
  esac
done


echo "Clearing logs from previous tests..."
rm -f ioread* iowrite*

echo "Flush & drop caches, because we want to test disk and not memory"
echo "This may take a few seconds."
sync
sysctl -w vm.drop_caches=3
echo "Flushed."

echo "Starting read tests..."
for ((i = 1; i <= num_of_reads; i++)); do
  ./read.sh > ioread${i} 2>&1 &
  echo -n '.'
done
echo
echo "Starting write tests..."
for ((i = 1; i <= num_of_writes; i++)); do
  ./write.sh > iowrite${i} 2>&1 &
  echo -n '.'
done
echo

echo "Tests have started. Run ./result.sh to view the statistics."
