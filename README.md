# NF-BORE - A Nextflow variant calling pipeline 

## Overview

This project aims to create a streamlined variant calling pipeline using Nextflow and Docker. We provide a sample set of reads from chr21 + chr22 from the NA12878 cell line.

## Samples

Read samples have been sampled from the [nf-core/test-datasets](https://github.com/nf-core/test-datasets/tree/sarek/) repository. We are currently using the full *tiny* set of reads. File paths are sourced by our pipeline using ```assets/samplesheet.csv```, so if you are updating the reads make sure to change the paths in that file.

Not included are reference genome files; the main ```.fa``` file is not included due to its size, and all indices based on that file are excluded so you do not needs to source our exact copy. If you are looking for the reference we use, it is the hg38 analysis set provided by University of California Santa Cruz [at this link](https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/analysisSet/).

## Running 

There is currently not much in the way of configuration for this project, so running running this pipeline is as simple as calling it with the Nextflow CLI.

``` bash
nextflow run main.nf
```
