#!/bin/bash

VERSION=1.0

usage(){
cat <<EOF
Usage:
  ./searchK.sh -m chrM_rev.fa -n chr.fa

Binary search for best K value.
  -m   reverse mitochondrial genome: [$chrM_rev]
  -n   nulcear genome: [$chr]
  -o   output prefix: [$output_prefix]
  -t   number of threads / parallel processes [$processes]
  -s   start of range: [$k_start]
  -e   end of range: [$k_end]
  -V   show script version
  -h   show this help
EOF
exit 0; }

SCR=`basename $0`;

# Execute getopt and check opts/args
ARGS=`getopt -n "$SCR" -o "m:n:o:t:s:e:hV" -- "$@"`
[ $? -ne 0 ] && exit 1; # Bad arguments
eval set -- "$ARGS"

plastz_script="/app/PLastZ.py"
lo_options="--format=maf-"
processes=2
output_prefix="chr_vs_mt_rev"

k_start=2000
k_end=3000

while true; do
    case "$1" in
        -m) [ ! -n "$2" ] && (echo "$1: value required" 1>&2 && exit 1); chrM_rev="$2"; shift 2;;
        -n) [ ! -n "$2" ] && (echo "$1: value required" 1>&2 && exit 1); chr="$2"; shift 2;;
        -o) [ ! -n "$2" ] && (echo "$1: value required" 1>&2 && exit 1); output_prefix="$2"; shift 2;;
        -t) [ ! -n "$2" ] && (echo "$1: value required" 1>&2 && exit 1); processes="$2"; shift 2;;
        -s) [ ! -n "$2" ] && (echo "$1: value required" 1>&2 && exit 1); k_start="$2"; shift 2;;
        -e) [ ! -n "$2" ] && (echo "$1: value required" 1>&2 && exit 1); k_end="$2"; shift 2;;
        -h) usage && exit 0;;
        -V) echo $VERSION && exit 0;;
        --) shift; break;;
    esac
done;

# Check mandatory options
if [ -z "$chrM_rev" ] || [ -z "$chr" ]; then
    echo "Mandatory options -m and -n are required."
    exit 1
fi

# Binary search for best K value
binary_search_best_k () {
    local low=$1 high=$2
    local mid best_k valid_k=0

    while [ $low -le $high ]; do
        mid=$(((low + high) / 2))
        echo "Testing K = $mid"

        if python $plastz_script $chrM_rev $chr $output_prefix -p $processes -lo "$lo_options K=$mid"; then
            if [ -s "$output_prefix/plastz.out" ]; then
                echo "Run $mid resulted in non-empty output"
                best_k=$mid
                valid_k=1
                low=$((mid + 1))
            else
                high=$((mid - 1))
            fi
        else
            echo "Script failed for K = $mid"
            high=$((mid - 1))
        fi
    done

    if [ $valid_k -eq 1 ]; then
        best_k=$((best_k + 1))
        echo "The best K value is: $best_k"
    else
        echo "No valid K value found within the given range."
    fi
}

# Execute the search
binary_search_best_k $k_start $k_end
