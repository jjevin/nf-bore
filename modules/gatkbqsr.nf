#!/usr/bin/env nextflow

process GATK_BQSR {

    tag "${meta.id}"

    container 'quay.io/biocontainers/gatk4:4.4.0.0--py36hdfd78af_0'
    
    input:
    tuple val(meta), path(bam)
    tuple val(meta_bai), path(bai)
    path fasta
    path fasta_index
    path dbsnp
    path dbsnp_tbi
    
    output:
    tuple val(meta), path("${meta.id}_recal.bam"),   emit: bam
    tuple val(meta), path("${meta.id}_recal.bai"),   emit: bai
	tuple val(meta), path("${meta.id}_recal.table"), emit: table

    script:
    """
	gatk BaseRecalibrator \
		-I ${bam} \
		-R ${fasta} \
		--known-sites ${dbsnp} \
		-O ${meta.id}_recal.table

	gatk ApplyBQSR \
		-I ${bam} \
		-R ${fasta} \
		--bqsr-recal-file ${meta.id}_recal.table \
		-O ${meta.id}_recal.bam \
		--create-output-bam-index true
	"""
}
