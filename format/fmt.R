#!/usr/bin/env Rscript
options(warn = -1)




a <- readLines(
    file("stdin"),
    warn = F
)

tryCatch(
    {
        fmtcode <- formatR::tidy_source(
            text = a, comment = T, arrow = T, indent = 4, width.cutoff = 80, args.newline = TRUE,
            brace.newline = F
        )

        write(fmtcode$tidy.text, file = stdout(), sep = "\n")
    }, warning = function(e) {
        write(a, file = stdout(), sep = "\n")
    }, error = function(e) {
        write(a, file = stdout(), sep = "\n")
    }
)
