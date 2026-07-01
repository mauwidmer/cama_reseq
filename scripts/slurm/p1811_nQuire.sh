#!/bin/bash

#SBATCH --job-name=nQuire_p1811
#SBATCH --partition=kenlab2
#SBATCH --nodelist=fgcz-kl-004
#SBATCH --output=./log/p1811_Cama_nQuire_%a.out
#SBATCH --time=0-05:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --array=1-26

set -euo pipefail

# load conda
. "/usr/local/ngseq/miniforge3/etc/profile.d/conda.sh"
conda activate /srv/kenlab/maurin/envs/nQuire

# load sample list
SAMPLE_LIST="/srv/kenlab/maurin/cama_reseq/data/raw/reseqs/sample_list_p1811.txt"

SAMPLE_ID=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SAMPLE_LIST")

BAM="/scratch/maurin/cama_reseq/data/BAM/p1811/${SAMPLE_ID}.bam"

OUTDIR="/scratch/maurin/cama_reseq/results/nQuire/p1811"
mkdir -p "$OUTDIR"

if [[ -z "$SAMPLE_ID" ]]; then
    echo "ERROR: No sample found for task ${SLURM_ARRAY_TASK_ID}"
    exit 1
fi

if [[ ! -f "$BAM" ]]; then
    echo "ERROR: BAM not found: $BAM"
    exit 1
fi

# run nQuire
echo "Processing sample: $SAMPLE_ID"
echo "Input : $BAM"
echo "Output: $OUTDIR"
echo

nQuire create -b "$BAM" -o "$OUTDIR/${SAMPLE_ID}"

nQuire denoise "$OUTDIR/${SAMPLE_ID}.bin" -o "$OUTDIR/${SAMPLE_ID}_denoised"

nQuire lrdmodel "$OUTDIR/${SAMPLE_ID}_denoised.bin"

echo
echo "Finished sample: $SAMPLE_ID"
