#!/usr/bin/env nextflow

process TRIMMOMATIC {

    tag "${meta.id}_${meta.lane}"
    // publishDir "${params.outdir}/trimmomatic", mode: 'copy'

    container "quay.io/biocontainers/trimmomatic:0.40--hdfd78af_0"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("${meta.id}_${meta.lane}_R{1,2}_paired.fastq.gz"),   emit: reads
    tuple val(meta), path("${meta.id}_${meta.lane}_R{1,2}_unpaired.fastq.gz"), emit: unpaired

    // TODO: Good secondary project could be testing different trimming options / tools
    script:
    def (r1, r2) = reads
    """
    trimmomatic PE ${r1} ${r2} \
        ${meta.id}_${meta.lane}_R1_paired.fastq.gz ${meta.id}_${meta.lane}_R1_unpaired.fastq.gz \
        ${meta.id}_${meta.lane}_R2_paired.fastq.gz ${meta.id}_${meta.lane}_R2_unpaired.fastq.gz \
        ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 \
        SLIDINGWINDOW:4:15 \
        LEADING:3 TRAILING:3 \
        MINLEN:36
    """

}
