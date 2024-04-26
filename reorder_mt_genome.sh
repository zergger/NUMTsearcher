#!/bin/bash

VERSION=1.0

usage(){
cat <<EOF
Usage:
  ./reorder_mt_genome.sh -i mt_genome.fasta -o new_mt_genome.fasta

extract sequences of Numts.
  -i   input file [$input]
  -o   output file: [$output]
  -V   show script version
  -h   show this help
EOF
exit 0; }

SCR=`basename $0`;

# Execute getopt and check opts/args
ARGS=`getopt -n "$SCR" -o "i:o:n:hV" -- "$@"`
[ $? -ne 0 ] && exit 1; # Bad arguments
eval set -- "$ARGS"

input="mt_genome.fasta"
output="new_mt_genome.fasta"

while true; do
    case "$1" in
        -i) [ ! -n "$2" ] && (echo "$1: value required" 1>&2 && exit 1); input="$2"; shift 2;;
        -o) [ ! -n "$2" ] && (echo "$1: value required" 1>&2 && exit 1); output="$2"; shift 2;;
        -h) usage && exit 0;;
        -V) echo $VERSION && exit 0;;
        --) shift; break;;
    esac
done;

# Check mandatory options
if [ -z "$input" ] || [ -z "$output" ]; then
    echo "Mandatory options -i and -o are required."
    exit 1
fi

genome_length=$(seqkit stats $input | awk 'NR>1 {print $5}' | tr -d ',')

base_length=$((genome_length / 1000))
start_pos=$((base_length * 1000 / 2 + 1))
end_pos=$((start_pos - 1))

seqkit subseq -r $start_pos:$genome_length $input > part1.fasta

seqkit subseq -r 1:$end_pos $input > part2.fasta

seqkit concat part1.fasta part2.fasta -o $output

rm part1.fasta part2.fasta

echo "Created new mitochondrial genome starting at position $start_pos with length $genome_length"
