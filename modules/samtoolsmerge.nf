#!/usr/bin/env nextflow

process SAMTOOLS_MERGE {

    tag "${meta.id}"

    container "docker.io/biocontainers/samtools:v1.7.0_cv4"

    input:
    tuple val(meta), path(bams)

    output:
    // Separate bam and bai channels since most downstream tools find
    // the index file by appending .bai to the bam path (therefore we'll
	// need to pass both channels to those processes)
    tuple val(meta), path("${meta.id}_merged.bam"),   	emit: bam
    tuple val(meta), path("${meta.id}_merged.bam.bai"), emit: bai

    script:
    """
	samtools merge ${meta.id}_merged.bam ${bams} -f
	samtools index ${meta.id}_merged.bam
	"""
    /* Common samtools merge flags to consider:
     * -f 		  Force overwrite of output
     * -n 		  Input is sorted by name, not coordinate
     * -r 		  Attach RG tag to each read based on source file header
     * 			  (already included during bwamem process)
     * --threads  Need to set up task.cpus
     * -c 		  Combine identical RG headers across files
     */

}
