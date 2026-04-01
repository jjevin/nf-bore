#!/usr/bin/env nextflow

/*
 * Run FastQC on input reads
 */
process FASTQC {

    container "community.wave.seqera.io/library/trim-galore:0.6.10--1bf8ca4e1967cd18"

    input: 
    // Passing multiple values, but this expands automatically
    path reads

    output:
    path "*_fastqc.zip",  emit: zip
    path "*_fastqc.html", emit: html

    script:
    """
    fastqc ${reads}
    """

}
