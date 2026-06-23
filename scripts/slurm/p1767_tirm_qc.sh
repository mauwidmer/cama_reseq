#!/bin/bash

#SBATCH --job-name=qc_p1767_trim
#SBATCH --partition=kenlab2
#SBATCH --nodelist=fgcz-kl-004
#SBATCH --output=./log/p1767_Cama_trim_qc.out
#SBATCH --time=0-10:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G

. "/usr/local/ngseq/miniforge3/etc/profile.d/conda.sh"
conda activate /srv/kenlab/maurin/envs/cama_qc

set -euo pipefail
shopt -s nullglob

INDIR="/srv/kenlab/maurin/cama_reseq/data/raw/reseqs/p1767"
OUTDIR="/scratch/maurin/cama_reseq/data/trimmed/reseqs/p1767_qc"
ADAPTER="/srv/kenlab/maurin/cama_reseq/data/adapters/adapters.fasta"

FASTQC_OUTDIR="${OUTDIR}/fastqc"
FASTP_OUTDIR="${OUTDIR}/fastp"
TRIMMED_OUTDIR="${OUTDIR}/trimmed"

#Creating the list of sample
echo "Setting up sample list"
SAMPLE_LIST=()

for f in "$INDIR"/*_R1*.fastq.gz; do
    base=$(basename "$f")
    sample=${base%%_R1*.fastq.gz}
    SAMPLE_LIST+=("$sample")
done

echo "${SAMPLE_LIST[@]}"

mkdir -p "$OUTDIR" "$FASTQC_OUTDIR" "$FASTP_OUTDIR" "$TRIMMED_OUTDIR"
cd "$OUTDIR"

# Running FastP with trimming
echo "starting fastp (with trimming)..."
for sample in "${SAMPLE_LIST[@]}"; do

    echo "SAMPLE ID : ${sample}"

    fastp --in1 "${INDIR}/${sample}_R1_001.fastq.gz" \
          --in2 "${INDIR}/${sample}_R2_001.fastq.gz" \
          --out1 "${TRIMMED_OUTDIR}/${sample}_R1_001_trimmed.fastq.gz" \
          --out2 "${TRIMMED_OUTDIR}/${sample}_R2_001_trimmed.fastq.gz" \
          --adapter_fasta "${ADAPTER}" \
          --detect_adapter_for_pe \
          --disable_quality_filtering \
          --disable_length_filtering \
          --json "${FASTP_OUTDIR}/${sample}.json" \
          --html "${FASTP_OUTDIR}/${sample}.html" \
          --thread "$SLURM_CPUS_PER_TASK"
done

# Running FastQC
echo "starting fastqc..."
for sample in "${SAMPLE_LIST[@]}"; do

    echo "SAMPLE ID : ${sample}"

    fastqc --outdir "$FASTQC_OUTDIR" \
           --threads "$SLURM_CPUS_PER_TASK" \
           "${TRIMMED_OUTDIR}/${sample}_R1_001_trimmed.fastq.gz" "${TRIMMED_OUTDIR}/${sample}_R2_001_trimmed.fastq.gz"
done

# Running MultiQC
echo "starting multiqc.."
multiqc "$OUTDIR" --force --filename "Cama_p1767_trim_mqc.html"

echo "Quality Controle finished"
