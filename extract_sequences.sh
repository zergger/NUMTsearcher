#!/bin/bash

VERSION=1.0

usage(){
cat <<EOF
Usage:
  ./extract_sequences.sh -i input.plastz -o output_sequences.fa -n chr1

extract sequences of Numts.
  -i   input file [$input_file]
  -o   output file: [$output_file]
  -n   seq name: [$seq_name]
  -V   show script version
  -h   show this help
EOF
exit 0; }

SCR=`basename $0`;

# Execute getopt and check opts/args
ARGS=`getopt -n "$SCR" -o "i:o:n:hV" -- "$@"`
[ $? -ne 0 ] && exit 1; # Bad arguments
eval set -- "$ARGS"

input_file="input.plastz"
output_file="output_sequences.fa"
seq_name="chr1"

while true; do
    case "$1" in
        -i) [ ! -n "$2" ] && (echo "$1: value required" 1>&2 && exit 1); input_file="$2"; shift 2;;
        -o) [ ! -n "$2" ] && (echo "$1: value required" 1>&2 && exit 1); output_file="$2"; shift 2;;
        -n) [ ! -n "$2" ] && (echo "$1: value required" 1>&2 && exit 1); seq_name="$2"; shift 2;;
        -h) usage && exit 0;;
        -V) echo $VERSION && exit 0;;
        --) shift; break;;
    esac
done;

# Check mandatory options
if [ -z "$input_file" ] || [ -z "$output_file" ]; then
    echo "Mandatory options -i and -o are required."
    exit 1
fi

awk -v seq_name="$seq_name" '
    $1 == "s" && index($2, seq_name) > 0 {
        seq = $7;
        gsub(/-/, "", seq);
        print ">" seq_name "\n" seq;
    }
' "$input_file" | seqkit rmdup -s - | seqkit rename -w 0 - > "$output_file"

echo "Processed sequences have been saved to $output_file"
