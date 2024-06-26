// workflow to read a CSV file with sample names and read files
// and emit them as tuples for downstream analysis

def hasExtension(it, extension) {
    it.toString().toLowerCase().endsWith(extension.toLowerCase())
}

params.input = params.outdir + '/stats/preprocessed_reads.csv'

workflow input_check {
    main:
    if(hasExtension(params.input, "csv")){
        // extracts read files from samplesheet CSV and distribute into channels
        ch_input = Channel
            .from(file(params.input))
            .splitCsv(header: true)
            .map { row ->
                    if (row.size() == 4) {
                        def sampleid = row.sampleID
                        def forward = row.forward ? file(row.forward, checkIfExists: true) : false
                        def reverse = row.reverse ? file(row.reverse, checkIfExists: true) : false
                        def orphans = row.orphans ? file(row.orphans, checkIfExists: true) : false
                        // Check if given combination is valid
                        if (!forward) exit 1, "Invalid input samplesheet: Forward can not be empty."
                        if (!reverse) exit 1, "Invalid input samplesheet: Reverse can not be empty."
                        if (!orphans) 
                            return [ sampleid, [ forward, reverse ] ] 
                        else 
                            return [ sampleid, [ forward, reverse, orphans ] ]
                    } else {
                        exit 1, "Input samplesheet contains row with ${row.size()} column(s). Expects 4."
                    }
             }
    } else {
        exit 1, "Input samplesheet should be a csv file organised like this:\n\nsampleID,forward,reverse,orphans"
    }
   
    emit:
    reads = ch_input
}
