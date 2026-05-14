#!/usr/bin/env nextflow

process BWA_MEM {

    tag "${meta.id}_${meta.lane}"

    // mulled container: bwa 0.7.19 + samtools 1.19
    container "quay.io/biocontainers/mulled-v2-fe8faa35dbf6dc65a0f7f5d4ea12e31a79f73e40:219b6c272b25e7e642ae3ff0bf0c5c81a5135ab4-0"

    input:
    tuple val(meta), path(reads)
    path fasta
    // indices not referred to directly, but scanned for by bwa mem
    path index 

    output:
    tuple val(meta), path("${meta.id}_${meta.lane}.bam"),   emit: bam

    script:
    // Read group string required by GATK downstream
    def rg = "@RG\\tID:${meta.id}_${meta.lane}\\tSM:${meta.id}\\tPL:ILLUMINA\\tLB:${meta.id}_lib"
    def (r1, r2) = reads
    """
    bwa mem \
        -R '${rg}' \
        -M \
        ${fasta} \
        ${r1} ${r2} \
    | samtools sort -o ${meta.id}_${meta.lane}.bam
    """

}
