#!/usr/bin/env nextflow

process GATK_DUPLICATES {

    tag "${meta.id}"

    // TODO: Having issues with biocontainer
    // will replace in the future
    container 'broadinstitute/gatk:4.1.3.0'

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("${meta.id}.bam"),	emit: bam
    path("${meta.id}.bam"), 					emit: metrics

    script:
    """
	gatk MarkDuplicates \
		-I ${bam} \
		-O ${meta.id}.bam \
		-M ${meta.id}.txt \
	"""
}
