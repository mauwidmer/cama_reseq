#!/bin/bash

INDIR="/srv/kenlab/maurin/cama_reseq/data/raw/reseqs/"

echo "Creating list of sample"
echo

read -p "Which sample set would you like to create an ID list of? " SAMPLE_SET

if [[ ! -d "$INDIR/$SAMPLE_SET" ]]; then
    echo "ERROR: $INDIR/$SAMPLE_SET does not exist"
    exit 1
fi

echo
echo "Setting up sample list"

SAMPLE_LIST=()

for f in "$INDIR"/"$SAMPLE_SET"/*_R1*.fastq.gz; do
    base=$(basename "$f")
    sample=${base%%_R1*.fastq.gz}
    SAMPLE_LIST+=("$sample")
done

OUTPUT="$INDIR"/"sample_list_${SAMPLE_SET}.txt"

printf "%s\n" "${SAMPLE_LIST[@]}" > "$OUTPUT"

echo
echo "Created $OUTPUT with ${#SAMPLE_LIST[@]} samples."
