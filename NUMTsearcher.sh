#!/bin/bash

VERSION=1.0

usage(){
cat <<EOF
Usage:
  ./NUMTsearcher.sh -m chrM.fa -n chr.fa

Binary search for best K value.
  -m   reverse mitochondrial genome: [$chrM]
  -n   nulcear genome: [$chr]
  -o   output prefix: [$output_prefix]
  -t   number of threads / parallel processes [$processes]
  -k   K value for PLastZ: [$k]
  -V   show script version
  -h   show this help
EOF
exit 0; }

SCR=`basename $0`;

# Execute getopt and check opts/args
ARGS=`getopt -n "$SCR" -o "m:n:o:t:k:hV" -- "$@"`
[ $? -ne 0 ] && exit 1; # Bad arguments
eval set -- "$ARGS"

plastz_script="/app/PLastZ.py"
lo_options="--format=maf-"
processes=2
output_prefix="chr_vs_mt"

k_start=2000
k_end=3000

while true; do
    case "$1" in
        -m) [ ! -n "$2" ] && (echo "$1: value required" 1>&2 && exit 1); chrM="$2"; shift 2;;
        -n) [ ! -n "$2" ] && (echo "$1: value required" 1>&2 && exit 1); chr="$2"; shift 2;;
        -o) [ ! -n "$2" ] && (echo "$1: value required" 1>&2 && exit 1); output_prefix="$2"; shift 2;;
        -t) [ ! -n "$2" ] && (echo "$1: value required" 1>&2 && exit 1); processes="$2"; shift 2;;
        -k) [ ! -n "$2" ] && (echo "$1: value required" 1>&2 && exit 1); k="$2"; shift 2;;
        -h) usage && exit 0;;
        -V) echo $VERSION && exit 0;;
        --) shift; break;;
    esac
done;

# Check mandatory options
if [ -z "$chrM" ] || [ -z "$chr" ]; then
    echo "Mandatory options -m and -n are required."
    exit 1
fi

if python $plastz_script $chrM $chr $output_prefix -p $processes -lo "$lo_options K=$k"; then
    if [ -s "$output_prefix/plastz.out" ]; then
        echo "Run NUMTsearcher at K = $k done!"
    else
        echo "Run $k resulted in empty output"
    fi
else
    echo "Script failed for K = $k"
fi







