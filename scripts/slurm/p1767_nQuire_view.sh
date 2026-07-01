#!/bin/bash

#SBATCH --job-name=nQuire_view_p1767
#SBATCH --partition=kenlab2
#SBATCH --nodelist=fgcz-kl-004
#SBATCH --output=./log/p1767_Cama_nQuire_view_%A_%a.out
#SBATCH --time=0-02:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G
#SBATCH --array=1-53

set -euo pipefail

# load conda
. "/usr/local/ngseq/miniforge3/etc/profile.d/conda.sh"
conda activate /srv/kenlab/maurin/envs/nQuire

# sample list
SAMPLE_LIST="/srv/kenlab/maurin/cama_reseq/data/raw/reseqs/sample_list_p1767.txt"
SAMPLE_ID=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SAMPLE_LIST")

# input/output
BINDIR="/scratch/maurin/cama_reseq/results/nQuire/p1767"
OUTDIR="/scratch/maurin/cama_reseq/results/nQuire/p1767/view"

mkdir -p "$OUTDIR"

BIN="${BINDIR}/${SAMPLE_ID}_denoised.bin"

echo "Processing sample: $SAMPLE_ID"
echo "Input : $BIN"
echo "Output: $OUTDIR"
echo

if [[ ! -f "$BIN" ]]; then
    echo "ERROR: Input file not found: $BIN"
    exit 1
fi

# Check file type (0 = standard, 1 = extended)
#nQuire view -f "$BIN" > "${OUTDIR}/${SAMPLE_ID}.bin_type.txt"

# Save per-position coverage/base counts
nQuire view "$BIN" > "${OUTDIR}/${SAMPLE_ID}.view.tsv"

# Save likelihood model results
nQuire lrdmodel -t ${SLURM_CPUS_PER_TASK} "$BIN" \
    > "${OUTDIR}/${SAMPLE_ID}.lrdmodel.tsv"

echo
echo "Finished sample: $SAMPLE_ID"
