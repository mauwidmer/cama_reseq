# cama_reseq

This project was conducted as a lab rotation for the CBB master's degree.

## Overview

This repository contains scripts and configuration files for data processing of C. amara collected by the Shimizu Lab. The project incolve QC, read mapping and SNP calling, and analysis of the genome for genes involved with C. amaras adaptation to its environment.

## Directory Structure

* `scripts/` – analysis and QC scripts
* `data/` – generated outputs (no fastq files)

## Usage

This repository is only ment as a communication tool to show the current state of the project and share the scripts within the group.

## Requirements

Dependencies and software versions will be documented here.

###Environments 
For this project we defined multiple conda environments to reduce conflicts:
- cama_qc: fastqc (0.12.1), fastp (1.3.4), multiqc (2.22.1)
- cama_bwa: bwa (0.7.19), samtools (1.20)

## Notes

This repository tracks code and metadata only. Large datasets are stored separately and are not included in version control.

