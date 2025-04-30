// workflow to read a CSV file with sample names and read files
// and emit them as tuples for downstream analysis

def hasExtension(it, extension) {
    it.toString().toLowerCase().endsWith(extension.toLowerCase())
}

workflow input_raw {
    main:
    if(hasExtension(params.raw_reads, "csv")){
        // extracts read files from samplesheet CSV and distribute into channels
        ch_input = Channel
            .from(file(params.raw_reads))
            .splitCsv(header: true)
            .map { row ->
                    if (row.size() == 3) {
                        def sampleid = row.sampleID
                        def forward = row.forward ? file(row.forward, checkIfExists: true) : false
                        def reverse = row.reverse ? file(row.reverse, checkIfExists: true) : false
                        // Check if given combination is valid
                        if (!forward) exit 1, "Invalid raw read (paired short read) samplesheet: Forward can not be empty."
                        if (!reverse) exit 1, "Invalid raw read (paired short read) samplesheet: Reverse can not be empty."
                        return [ sampleid, forward, reverse]
                    } else {
                        exit 1, "Raw read samplesheet (paired short read) contains row with ${row.size()} column(s). Expects 3."
                    }
             }
        ch_reads = ch_input
            .map { sampleid, forward, reverse ->
                        return [ sampleid, [ forward, reverse ] ]
                }
    } else {
        exit 1, "Raw read samplesheet (paired short read) should be a csv file organised like this:\n\nsampleID,forward,reverse"
    }
   
    emit:
    reads = ch_reads
}

workflow input_raw_lr {
    main:
    if(hasExtension(params.raw_reads, "csv")){
        // extracts read files from samplesheet CSV and distribute into channels
        ch_input = Channel
            .from(file(params.raw_reads))
            .splitCsv(header: true)
            .map { row ->
                    if (row.size() == 2) {
                        def sampleid = row.sampleID
                        def reads = row.reads ? file(row.reads, checkIfExists: true) : false
                        // Check if given combination is valid
                        if (!reads) exit 1, "Invalid raw read (long reads) samplesheet: Reads can not be empty."
                        return [ sampleid, reads]
                    } else {
                        exit 1, "Raw read samplesheet (long reads) contains row with ${row.size()} column(s). Expects 2."
                    }
             }  
    } else {
        exit 1, "Raw read samplesheet (long reads) should be a csv file organised like this:\n\nsampleID,reads"
    }
   
    emit:
    reads = ch_input
}


workflow input_raw_single_end {
    main:
    if(hasExtension(params.raw_reads, "csv")){
        // extracts read files from samplesheet CSV and distribute into channels
        ch_input = Channel
            .from(file(params.raw_reads))
            .splitCsv(header: true)
            .map { row ->
                    if (row.size() == 2) {
                        def sampleid = row.sampleID
                        def reads = row.reads ? file(row.reads, checkIfExists: true) : false
                        // Check if given combination is valid
                        if (!reads) exit 1, "Invalid raw read (single-end short read) samplesheet: Reads can not be empty."
                        return [ sampleid, reads]
                    } else {
                        exit 1, "Raw read samplesheet (single-end short read) contains row with ${row.size()} column(s). Expects 2."
                    }
             }
        ch_reads = ch_input
            .map { sampleid, reads ->
                        return [ sampleid, [ reads ] ]
                }
    } else {
        exit 1, "Raw read samplesheet (single-end short read) should be a csv file organised like this:\n\nsampleID,reads"
    }
   
    emit:
    reads = ch_reads
}

