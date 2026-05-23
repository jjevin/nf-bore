#!/usr/bin/env nextflow

include { FASTQC } from './modules/fastqc.nf'
include { TRIMMOMATIC } from './modules/trimmomatic.nf'
include { FASTQC as FASTQC_TRIMMED } from './modules/fastqc.nf'
include { BWA_MEM } from './modules/bwamem.nf'
include { SAMTOOLS_MERGE } from './modules/samtoolsmerge.nf'
include { GATK_DUPLICATES } from './modules/gatkduplicates.nf'
include { GATK_BQSR } from './modules/gatkbqsr.nf'
include { GATK_HAPLOTYPE } from './modules/gatkhaplotype.nf'

workflow {

    main: 
    // Alternative convention to ch_reads = Channel...
    // TODO: Need to look in to groovy's dynamic closure syntax
    Channel
        .fromPath(params.input)
        .splitCsv(header: true)
        .map { row -> 
            def meta = [id: row.sample, lane: row.lane] 
            def reads = [
                file("${projectDir}/${row.fastq_1}"), 
                file("${projectDir}/${row.fastq_2}")
            ]
            [meta, reads]
        }
        .set { ch_reads }

    FASTQC(ch_reads) 
    TRIMMOMATIC(ch_reads)
    FASTQC_TRIMMED(TRIMMOMATIC.out.reads)

    // Collect just the fasta file, no indices
    ch_fasta = Channel.value(file(params.fasta))
    // "hg38.analysisSet.fa.gz.*" matches .amb, .ann, .bwt, .pac, .sa
    // but NOT hg38.analysisSet.fa.gz itself
    ch_index = Channel.fromPath("${params.fasta}.*").collect()

    BWA_MEM(TRIMMOMATIC.out.reads, ch_fasta, ch_index)

    // Merging samples sequenced across multiple lanes
    // TODO: Groovy syntax, def vs no def in dynamic closure?
    // - Does groupTuple always key off of the first element?
    BWA_MEM.out.bam
    	.map { meta, bam -> [meta.id, meta, bam] } 		// key by sample id
    	.groupTuple()									// collect all lanes per sample
    	.map { id, metas, bams -> [metas[0], bams] } 	// drop the key, keep first meta + bam list
    	.set { ch_bams_merged }
    
    SAMTOOLS_MERGE(ch_bams_merged)
    GATK_DUPLICATES(SAMTOOLS_MERGE.out.bam)

    GATK_BQSR(
        GATK_DUPLICATES.out.bam,
        GATK_DUPLICATES.out.bai,
        params.fasta,
        params.fasta_fai,
        params.fasta_dict,
        params.fasta_gzi,
        params.dbsnp,
        params.dbsnp_tbi,
    )

    GATK_HAPLOTYPE(
        GATK_BQSR.out.bam,
        GATK_BQSR.out.bai,
        params.fasta,
        params.fasta_fai,
        params.fasta_dict,
        params.fasta_gzi
    )
    
    publish:
    fastqc_zip = FASTQC.out.zip
    fastqc_html = FASTQC.out.html
    trimmomatic_reads = TRIMMOMATIC.out.reads
    trimmomatic_unpaired = TRIMMOMATIC.out.unpaired
    fastqc_trimmed_zip = FASTQC_TRIMMED.out.zip
    fastqc_trimmed_html = FASTQC_TRIMMED.out.html
    bwa_mem_bam = BWA_MEM.out.bam
    samtools_merge_bam = SAMTOOLS_MERGE.out.bam
    samtools_merge_bai = SAMTOOLS_MERGE.out.bai
    gatk_duplicates_bam = GATK_DUPLICATES.out.bam
    gatk_duplicates_bai = GATK_DUPLICATES.out.bai
    gatk_duplicates_metrics = GATK_DUPLICATES.out.metrics
    gatk_bqsr_bam = GATK_BQSR.out.bam
    gatk_bqsr_bai = GATK_BQSR.out.bai
    gatk_bqsr_table = GATK_BQSR.out.table
    gatk_haplotype_vcf = GATK_HAPLOTYPE.out.vcf
    
}

// TODO: Compare against original output syntax (per-process)
output {
    fastqc_zip {
        path 'fastqc'
    }
    fastqc_html {
        path 'fastqc'
    }
    trimmomatic_reads { 
        path 'trimmomatic' 
    }
    trimmomatic_unpaired {
        path 'trimmomatic'
    }
    fastqc_trimmed_zip {
        path 'fastqc_trimmed'
    }
    fastqc_trimmed_html {
        path 'fastqc_trimmed'
    }
    bwa_mem_bam {
        path 'bwa_mem_bam'
    }
    samtools_merge_bam {
        path 'samtools_merge'
    }
    samtools_merge_bai {
        path 'samtools_merge'
    }
    gatk_duplicates_bam {
        path 'gatk_duplicates'
    }
    gatk_duplicates_bai {
        path 'gatk_duplicates'
    }
    gatk_duplicates_metrics {
        path 'gatk_duplicates'
    }
    gatk_bqsr_bam {
        path 'gatk_bqsr'
    }
    gatk_bqsr_bai {
        path 'gatk_bqsr'
    }
    gatk_bqsr_table {
        path 'gatk_bqsr'
    }
    gatk_haplotype_vcf {
        path 'gatk_haplotype'
    }
}
