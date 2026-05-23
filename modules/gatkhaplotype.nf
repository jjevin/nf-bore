#!/usr/bin/env nextflow

process GATK_HAPLOTYPE {

    tag "${meta.id}"

    container 'quay.io/biocontainers/gatk4:4.4.0.0--py36hdfd78af_0'
    
    input:
    tuple val(meta), path(bam)
    tuple val(meta_bai), path(bai)
    path fasta
    path fasta_fai
    path fasta_dict
    path fasta_gzi
    
    output:
    tuple val(meta), path("${meta.id}.g.vcf.gz"), 	  emit: gvcf
    tuple val(meta), path("${meta.id}.g.vcf.gz.tbi"), emit: tbi

    script:
    """
	gatk HaplotypeCaller \
		-R ${fasta} \
		-I ${bam} \
		-O ${meta.id}.g.vcf.gz \
		-ERC GVCF
	"""

}
