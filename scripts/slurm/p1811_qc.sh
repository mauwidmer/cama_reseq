#!/bin/bash

#SBATCH --job-name=qc_p1811
#SBATCH --partition=kenlab2
#SBATCH --nodelist=fgcz-kl-003
#SBATCH --output=./log/p1811_Cama_qc.out
#SBATCH --time=0-10:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G

. "/usr/local/ngseq/miniforge3/etc/profile.d/conda.sh"
conda activate /srv/kenlab/maurin/envs/cama_qc

set -euo pipefail
shopt -s nullglob

INDIR="/srv/kenlab/maurin/cama_reseq/data/raw/reseqs/p1811"
OUTDIR="/srv/kenlab/maurin/cama_reseq/data/raw/reseqs/p1811_qc"

FASTQC_OUTDIR="${OUTDIR}/fastqc"
FASTP_OUTDIR="${OUTDIR}/fastp"

#Creating the list of sample
echo "Setting up sample list"
SAMPLE_LIST=()

for f in "$INDIR"/*_R1.fastq.gz; do
    base=$(basename "$f")
    sample=${base%%_R1.fastq.gz}
    SAMPLE_LIST+=("$sample")
done

echo "${SAMPLE_LIST[@]}"

mkdir -p "$OUTDIR" "$FASTQC_OUTDIR" "$FASTP_OUTDIR"
cd "$OUTDIR"

# Running FastQC
echo "starting fastqc..."
for sample in "${SAMPLE_LIST[@]}"; do

    echo "SAMPLE ID : ${sample}"

    fastqc --outdir "$FASTQC_OUTDIR" \
           --threads "$SLURM_CPUS_PER_TASK" \
           "${INDIR}/${sample}_R1.fastq.gz" "${INDIR}/${sample}_R2.fastq.gz"
done

# Running FastP
echo "starting fastp..."
for sample in "${SAMPLE_LIST[@]}"; do

    echo "SAMPLE ID : ${sample}"

    fastp --in1 "${INDIR}/${sample}_R1.fastq.gz" \
          --in2 "${INDIR}/${sample}_R2.fastq.gz" \
          --stdout \
          --disable_quality_filtering \
          --disable_length_filtering \
          --disable_adapter_trimming \
          --json "${FASTP_OUTDIR}/${sample}.json" \
          --html "${FASTP_OUTDIR}/${sample}.html" \
          --thread "$SLURM_CPUS_PER_TASK" > /dev/null
done

# Running MultiQC
echo "starting multiqc..."
multiqc "$OUTDIR" --force --filename "Cama_p1811_mqc.html"

echo "Quality Controle finished"
