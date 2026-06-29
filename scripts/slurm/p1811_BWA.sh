#!/bin/bash

#SBATCH --job-name=bwa_p1811
#SBATCH --partition=kenlab2
#SBATCH --nodelist=fgcz-kl-004
#SBATCH --output=./log/p1811_Cama_bwa_%A_%a.out
#SBATCH --time=0-05:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --array=1-26

# load conda
. "/usr/local/ngseq/miniforge3/etc/profile.d/conda.sh"
conda activate /srv/kenlab/maurin/envs/cama_bwa

# load sample list
SAMPLE_LIST="/srv/kenlab/maurin/cama_reseq/data/raw/reseqs/sample_list_p1811.txt"

SAMPLE_ID=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SAMPLE_LIST")

if [[ -z "$SAMPLE_ID" ]]; then
    echo "ERROR: No sample found for task ${SLURM_ARRAY_TASK_ID}"
    exit 1
fi

# run pipeline
echo "Processing sample: $SAMPLE_ID"
echo

bash /srv/kenlab/maurin/cama_reseq/scripts/SNP_Calling/p1811/BWA_p1811.sh "$SAMPLE_ID"

echo
echo "Finished sample: $SAMPLE_ID"
