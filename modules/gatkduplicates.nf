#!/usr/bin/env nextflow

process GATK_DUPLICATES {

    tag "${meta.id}"

    container 'quay.io/biocontainers/gatk4:4.4.0.0--py36hdfd78af_0'

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("${meta.id}_markdup.bam"),	emit: bam
    tuple val(meta), path("${meta.id}_markdup.bai"),	emit: bai
    tuple val(meta), path("${meta.id}_metrics.txt"), 	emit: metrics

    script:
    """
	gatk MarkDuplicates \
		-I ${bam} \
		-O ${meta.id}_markdup.bam \
		-M ${meta.id}_metrics.txt \
		--CREATE_INDEX true \
	"""
}
