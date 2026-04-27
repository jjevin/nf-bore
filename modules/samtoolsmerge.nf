#!/usr/bin/env nextflow

process SAMTOOLS_MERGE {

    tag "${meta.id}"

    container "docker.io/biocontainers/samtools:v1.7.0_cv4"

    input:
    tuple val(meta), path(bams)

    output:
    tuple val(meta), path("${meta.id}_merged.bam"),   	emit: bam
    tuple val(meta), path("${meta.id}_merged.bam.bai"), emit: bai

    script:
    """
	samtools merge ${meta.id}_merged.bam ${bams}
	samtools index ${meta.id}_merged.bam
	"""

}
