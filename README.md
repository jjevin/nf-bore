# NF-BORE - A Nextflow variant calling pipeline 

## Overview

This project aims to create a streamlined variant calling pipeline using Nextflow and Docker. We provide a sample set of reads from chr21 + chr22 from the NA12878 cell line.

1. FastQC - Generating quality reports on raw reads
2. Trimmomatic - Trimming adapter and low quality sequences from reads
3. FastQC on Trimmomatic results - Updated quality report on trimmed reads
4. BWA MEM + SAMTOOLS INDEX - Aligning reads to reference genome and indexing
5. SAMTOOLS MERGE - Merging per-lane bam files on a per-sample basis
6. GATK Duplicates - Marking duplicate reads resulting from PCR
7. GATK BQSR - Adjusting base quality scores for systemic error
8. GATK Haplotype - Calling SNPs and indels on our post-processed bam
9. GATK GVCF - Joint genotyping step for datasets with many samples
10. GATK Filter - Filtering out variants with low confidence

## Prerequisites

This project was developed with the following software and versions:

* Nextflow version >=26.04
* Docker version >= 28.4.0
* OpenJDK version >= 25
* Approximately 10GB for reference files and reads
* All other dependencies are controlled via Docker

Please check for compatibility when running this pipeline with older versions of these dependencies.

## Setup

### Samples

Read samples have been sampled from the [nf-core/test-datasets](https://github.com/nf-core/test-datasets/tree/sarek/) repository. We are currently using the full *tiny* set of reads. File paths are sourced by our pipeline using ```assets/samplesheet.csv```; if you are running this pipeline with different read files, make sure to update the paths, lanes, and samples specified in the samplesheet.

This repository does not include reference genome files; the main ```.fa``` file is not included due to its size, and all indices based on that file are excluded so you do not need to source our exact copy. The pipeline is set to look for these files in the ```data/ref/``` directory, and this behavior can be modified in the ```nextflow.config``` file. If you are looking for the reference we use, it is the hg38 analysis set provided by University of California Santa Cruz [at this link](https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/analysisSet/). To download this file and generate the corresponding index files, run the following:

``` bash
# Getting our reference fasta
cd data/ref/
wget https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/analysisSet/hg38.analysisSet.fa.gz

# Converting to bgzip, since this is required by samtools and gatk
gzip -d hg38.analysisSet.fa
bgzip hg38.analysisSet.fa

# Creating our index files
samtools faidx hg38.analysisSet.fa.gz
samtools dict hg38.analysisSet.fa.gz
bwa index hg38.analysisSet.fa.gz
```

Our ```dbsnp``` files are also not included with this repository. These also go into the ```/data/ref/``` directory. If you are looking to use the same files we used in testing, run the following:

``` bash
cd data/ref/
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/hg38/dbsnp_146.hg38.vcf.gz
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/hg38/dbsnp_146.hg38.vcf.gz.tbi
```

### Configuration

Configuration is outlined in the ```nextflow.config``` file. Individual parameters may be specified when running using standard nextflow syntax (```nextflow run main.nf --{param} {param_value}```) or by modifying the values in the config file. For a brief overview of all parameters in the nextflow file: 

| Parameter       | Description               | Default                                  |
|-----------------|---------------------------|------------------------------------------|
| ```input```     | Path to samplesheet csv   | ```assets/samplesheet.csv```             |
| ```outdir```    | Path to results directory | ```results```                            |
| ```fasta```     | Path to fasta files       | ```data/ref/hg38.analysisSet.fa.gz```    |
| ```dbsnp```     | Path to dbsnp file        | ```data/ref/dbsnp_146.hg38.vcf.gz```     |
| ```dbsnp_tbi``` | Path to dbsnp tbi file    | ```data/ref/dbsnp_146.hg38.vcf.gz.tbi``` |
|                 |                           |                                          |

## Running 

There is currently not much in the way of configuration for this project, so running this pipeline is as simple as calling it with the Nextflow CLI.

``` bash
nextflow run main.nf
```

It is recommended to run the pipeline with the resume flag when repeating procedures, as this allows 

The typical runtime on my machine is approximately 15 minutes, with most of that being spent on the haplotype caller module. 

### Outputs

The results of each module are written in the ```results``` directory and are organized by module. Please refer to the overview section for an elaboration of the intent of each module and the contents of their outputs.
