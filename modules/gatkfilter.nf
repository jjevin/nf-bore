#!/usr/bin/env nextflow

process GATK_FILTER {

    tag "${meta.id}"

    container 'quay.io/biocontainers/gatk4:4.4.0.0--py36hdfd78af_0'

    input:
    tuple val(meta), path(vcf)
    tuple val(meta_tbi), path(tbi)
    path fasta
    path fasta_fai
    path fasta_dict
    path fasta_gzi

    output:
    tuple val(meta), path("${meta.id}_filtered.vcf.gz"),     emit: vcf
    tuple val(meta), path("${meta.id}_filtered.vcf.gz.tbi"), emit: tbi

    script:
    """
    gatk VariantFiltration \
        -R ${fasta} \
        -V ${vcf} \
        -O ${meta.id}_filtered.vcf.gz \
        --filter-expression "QD < 2.0"  --filter-name "QD2"  \
        --filter-expression "FS > 60.0" --filter-name "FS60" \
        --filter-expression "MQ < 40.0" --filter-name "MQ40" \
        --filter-expression "SOR > 3.0" --filter-name "SOR3" \
        --filter-expression "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum"
    """
    // Note: Docs showed --filterExpression and --filterName!
}
