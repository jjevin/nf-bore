#!/usr/bin/env nextflow

/*
 * Run FastQC on input reads
 */
process FASTQC {

    tag "${meta.id}_${meta.lane}"
    // publishDir "${params.outdir}/fastqc", mode: 'copy'
    
    container "quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0"

    input: 
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*_fastqc.zip"),  emit: zip
    tuple val(meta), path("*_fastqc.html"), emit: html

    script:
    """
    fastqc ${reads}
    """

}
