#!/bin/bash

set -euo pipefail

SAMPLE_ID=$1
FASTQ_DIR="/scratch/maurin/cama_reseq/data/trimmed/reseqs/p1811_qc/trimmed"
GENOME="/srv/kenlab/maurin/cama_reseq/data/ref_genome/ca1.genome.fasta.gz"
BAM_DIR="/scratch/maurin/cama_reseq/data/BAM/p1811"

cd "$BAM_DIR"
BAM="${BAM_DIR}/${SAMPLE_ID}.bam"
echo "Sample beeing processed:" "$SAMPLE_ID"

########################################
# Skip if index exists
########################################
if [[ -f "${BAM}.bai" ]]; then
    echo "Index exists (${BAM}.bai), skipping entire pipeline."
    exit 0
fi

########################################
# FASTQ files
########################################
R1="${FASTQ_DIR}/${SAMPLE_ID}_R1_trimmed.fastq.gz"
R2="${FASTQ_DIR}/${SAMPLE_ID}_R2_trimmed.fastq.gz"

if [[ ! -f "$R1" || ! -f "$R2" ]]; then
    echo "ERROR: FASTQ files not found"
    exit 1
fi

echo "$R1"
echo "$R2"
echo

########################################
# Run BWA + samtools
########################################
echo "Running BWA..."

bwa mem -M -t "$SLURM_CPUS_PER_TASK" \
        -R "@RG\tID:${SAMPLE_ID}\tSM:${SAMPLE_ID}\tLB:${SAMPLE_ID}\tPL:DNBSEQ" \
        "$GENOME" "$R1" "$R2" \
| samtools view -b \
| samtools sort -n -@ "$SLURM_CPUS_PER_TASK" -m 3G -o "${SAMPLE_ID}.namesort.bam"

samtools fixmate -m "${SAMPLE_ID}.namesort.bam" "${SAMPLE_ID}.fixmate.bam"
samtools sort -@ "$SLURM_CPUS_PER_TASK" -m 3G -o "${SAMPLE_ID}.sorted.bam" "${SAMPLE_ID}.fixmate.bam"
samtools markdup -@ "$SLURM_CPUS_PER_TASK" "${SAMPLE_ID}.sorted.bam" "$BAM"

rm "${SAMPLE_ID}.namesort.bam" "${SAMPLE_ID}.fixmate.bam" "${SAMPLE_ID}.sorted.bam"

########################################
# Stats
########################################
echo "Generating stats..."

samtools stats "$BAM" | awk '$1=="SN" {print $0}' > "${SAMPLE_ID}.stats"
samtools flagstat -O tsv "$BAM" > "${SAMPLE_ID}.flagstat.tsv"

########################################
# Index
########################################
echo "Indexing BAM..."

samtools index -@ "$SLURM_CPUS_PER_TASK" "$BAM"

echo "Done: $SAMPLE_ID"

