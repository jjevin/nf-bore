#!/usr/bin/env nextflow

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
    Channel
        .fromPath(params.input)
        .splitCsv(header: true)
        // TODO: Need to look in to groovy's dynamic closure syntax
        .map { row -> 
            def meta = [id: row.sample, lane: row.lane] 
            def reads = [file(row.fastq_1), file(row.fastq_2)] 
        }
        // .view()
        .set { ch_reads }

}

/*
output {
}
*/
