#!/usr/bin/env nextflow

include { FASTQC } from './modules/fastqc.nf'
include { TRIMMOMATIC } from './modules/trimmomatic.nf'
include { FASTQC as FASTQC_TRIMMED } from './modules/fastqc.nf'
include { BWA_MEM } from './modules/bwamem.nf'

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

    // Collect all index files as a single channel value
    ch_fasta = Channel.value(file(params.fasta))
    ch_index = Channel.fromPath("${params.fasta}.*").collect()
    // "hg38.analysisSet.fa.gz.*" matches .amb, .ann, .bwt, .pac, .sa
    // but NOT hg38.analysisSet.fa.gz itself

    BWA_MEM(TRIMMOMATIC.out.reads, ch_fasta, ch_index)

    // TODO: groupTuple on BWA_MEM.out.bam to merge lanes before MarkDuplicates

    publish:
    fastqc_zip = FASTQC.out.zip
    fastqc_html = FASTQC.out.html
    trimmomatic_reads = TRIMMOMATIC.out.reads
    trimmomatic_unpaired = TRIMMOMATIC.out.unpaired
    fastqc_trimmed_zip = FASTQC_TRIMMED.out.zip
    fastqc_trimmed_html = FASTQC_TRIMMED.out.html
    bwa_mem_bam = BWA_MEM.out.bam
    
}

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
}
