// workflow to read a CSV file with sample names and read files
// and emit them as tuples for downstream analysis

def hasExtension(it, extension) {
    it.toString().toLowerCase().endsWith(extension.toLowerCase())
}

params.preprocessed_reads = params.outdir + '/stats/preprocessed_reads.csv'

workflow input_check {
    main:
    if(hasExtension(params.preprocessed_reads, "csv")){
        // extracts read files from samplesheet CSV and distribute into channels
        ch_input = Channel
            .from(file(params.preprocessed_reads))
            .splitCsv(header: true)
            .map { row ->
                    if (row.size() == 4) {
                        def sampleid = row.sampleID
                        def forward = row.forward ? file(row.forward, checkIfExists: true) : false
                        def reverse = row.reverse ? file(row.reverse, checkIfExists: true) : false
                        def orphans = row.orphans ? file(row.orphans, checkIfExists: true) : false
                        // Check if given combination is valid
                        if (!forward) exit 1, "Invalid processed read samplesheet (paired short-read): Forward can not be empty."
                        if (!reverse) exit 1, "Invalid processed read samplesheet (paired short-read): Reverse can not be empty."
                        if (!orphans) 
                            return [ sampleid, [ forward, reverse ] ] 
                        else 
                            return [ sampleid, [ forward, reverse, orphans ] ]
                    } else {
                        exit 1, "Processed read samplesheet (paired short-read) contains row with ${row.size()} column(s). Expects 4."
                    }
             }
    } else {
        exit 1, "Processed read samplesheet (paired short-read) should be a csv file organised like this:\n\nsampleID,forward,reverse,orphans"
    }
   
    emit:
    reads = ch_input
}


workflow input_check_lr {
    main:
    if(hasExtension(params.preprocessed_reads, "csv")){
        // extracts read files from samplesheet CSV and distribute into channels
        ch_input = Channel
            .from(file(params.preprocessed_reads))
            .splitCsv(header: true)
            .map { row ->
                    if (row.size() == 2) {
                        def sampleid = row.sampleID
                        def reads = row.reads ? file(row.reads, checkIfExists: true) : false
                        // Check if given combination is valid
                        if (!reads) exit 1, "Invalid processed reads samplesheet (long reads): Reads can not be empty."
                        return [ sampleid, reads]
                    } else {
                        exit 1, "Processed reads samplesheet (long reads) contains row with ${row.size()} column(s). Expects 2."
                    }
             }
    } else {
        exit 1, "Processed reads samplesheet (long reads) should be a csv file organised like this:\n\nsampleID,reads"
    }
   
    emit:
    reads = ch_input
}


workflow input_check_single_end {
    main:
    if(hasExtension(params.preprocessed_reads, "csv")){
        // extracts read files from samplesheet CSV and distribute into channels
        ch_input = Channel
            .from(file(params.preprocessed_reads))
            .splitCsv(header: true)
            .map { row ->
                    if (row.size() == 2) {
                        def sampleid = row.sampleID
                        def reads = row.reads ? file(row.reads, checkIfExists: true) : false
                        // Check if given combination is valid
                        if (!reads) exit 1, "Invalid processed reads samplesheet (single-end short reads): Reads can not be empty."
                        return [ sampleid, reads]
                    } else {
                        exit 1, "Processed reads samplesheet (single-end short reads) contains row with ${row.size()} column(s). Expects 2."
                    }
             }
    } else {
        exit 1, "Processed reads samplesheet (single-end short reads) should be a csv file organised like this:\n\nsampleID,reads"
    }
   
    emit:
    reads = ch_input
}
