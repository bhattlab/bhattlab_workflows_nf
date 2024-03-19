// workflow to read a CSV file with sample names and read files
// and emit them as tuples for downstream analysis

def hasExtension(it, extension) {
    it.toString().toLowerCase().endsWith(extension.toLowerCase())
}

workflow input_raw {
    main:
    if(hasExtension(params.samples, "csv")){
        // extracts read files from samplesheet CSV and distribute into channels
        ch_input = Channel
            .from(file(params.samples))
            .splitCsv(header: true)
            .map { row ->
                    if (row.size() == 3) {
                        def sampleid = row.sampleID
                        def forward = row.forward ? file(row.forward, checkIfExists: true) : false
                        def reverse = row.reverse ? file(row.reverse, checkIfExists: true) : false
                        // Check if given combination is valid
                        if (!forward) exit 1, "Invalid input samplesheet: Forward can not be empty."
                        if (!reverse) exit 1, "Invalid input samplesheet: Reverse can not be empty."
                        return [ sampleid, forward, reverse]
                    } else {
                        exit 1, "Input samplesheet contains row with ${row.size()} column(s). Expects 3."
                    }
             }
        ch_reads = ch_input
            .map { sampleid, forward, reverse ->
                        return [ sampleid, [ forward, reverse ] ]
                }
    } else {
        exit 1, "Input samplesheet should be a csv file organised like this:\n\nsampleID,forward,reverse"
    }
   
    emit:
    reads = ch_reads
}
