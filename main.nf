#!/usr/bin/env nextflow

include { FASTQC } from './modules/fastqc.nf'

params {
    // fastq
    input: Path

    // fasta
    reference: Path
    reference_index: Path
    reference_dict: Path
}

workflow {

    main: 
    // Alternative convention to ch_reads = Channel...
    // TODO: Need to look in to groovy's dynamic closure syntax
    Channel
        .fromPath(params.input)
        .splitCsv(header: true)
        .map { row -> 
            def meta = [id: row.sample, lane: row.lane] 
            def reads = [file(row.fastq_1), file(row.fastq_2)] 
        }
        .set { ch_reads }

    FASTQC(ch_reads) 

    publish:
    fastqc_zip = FASTQC.out.zip
    fastqc_html = FASTQC.out.html

}

output {
    fastqc_zip {
        path 'fastqc'
    }
    fastqc_html {
        path 'fastqc'
    }
}
