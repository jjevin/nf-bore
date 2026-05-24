#!/usr/bin/env nextflow

process GATK_GVCF {

    tag "${meta.id}"

    container 'quay.io/biocontainers/gatk4:4.4.0.0--py36hdfd78af_0'
    
    input:
    tuple val(meta), path(gvcf)
    tuple val(meta_tbi), path(tbi)
    path fasta
    path fasta_index

    output:
    tuple val(meta), path("${meta.id}.vcf.gz"), emit: vcf
    tuple val(meta), path("${meta.id}.vcf.gz.tbi"), emit: tbi

    script:
    """
	gatk GenotypeGVCFs \
		-R ${fasta} \
		-V ${gvcf} \
		-O ${meta.id}.vcf.gz
	"""
    // TODO: Look into genomicsdb for multi-sample work

}
