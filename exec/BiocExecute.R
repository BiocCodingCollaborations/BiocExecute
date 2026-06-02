#!/usr/bin/env Rapp
#| name: BiocExecute
#| title: Replace with a short title
#| description: |
#|   Replace with a description of what this tool does.

#| description: Input .rds file
input <- NULL

#| description: Output .rds file path
output <- NULL

library(BiocExecute)

obj <- readRDS(input)

# Implement workflow
# --OR--
# Write sub scripts into exec/scripts/
#   and call the compiler function
obj <- foo(bar(obj))

saveRDS(obj, output)
message("Done. Saved to: ", output)
