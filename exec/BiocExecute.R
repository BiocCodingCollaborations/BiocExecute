#!/usr/bin/env Rapp
#| name: BiocExecute
#| title: Make package functions or workflows executable in the command line.
#| description: |
#|   The BiocExecute package should be used by a package maintainer
#|   that wants to make his/her package functions and/or workflows executable in
#|   the command line.

switch(
  "",

  #| name: templateCommand
  #| title: Template Command (name is used as command)
  #| description: Template function demonstrating all Rapp parameter
  #|   types.
  templateCommand = {

    #| description: Required positional argument (no default).
    #| val_type: string
    inputFile <- NULL

    #| description: Optional positional argument.
    #| required: false
    #| val_type: string
    outputFile <- NULL

    #| description: Character option with default value.
    #| short: f
    #| val_type: string
    format <- "csv"

    #| description: Numeric vector for multiple values.
    #| short: t
    #| val_type: float
    thresholds <- c()

    #| description: List for parsed values (integers, floats, etc.).
    #| short: i
    #| val_type: integer
    indices <- list()

    #| description: Boolean switch to enable verbose output.
    #| short: v
    verbose <- FALSE

    ## Example usage of the parameters
    message("Input file: ", inputFile)
    if (!is.null(outputFile)) {
        message("Output file: ", outputFile)
    }
    message("Format: ", format)
    if (length(thresholds) > 0) {
        message("Thresholds: ", paste(thresholds, collapse = ", "))
    }
    if (length(indices) > 0) {
        message("Indices: ", paste(indices, collapse = ", "))
    }
    if (verbose) {
        message("Verbose mode enabled")
    }
  },

  #| name: execCompile
  #| title: Compile package scripts into a Rapp executable
  #| description:
  #| Collect the R scripts stored in a package's ‘exec/scripts’
  #| directory and combine them into one Rapp executable
  #| containing a ‘switch()’ entry for each script.
  execCompile = {

    #| description: A path to the R package directory.
    #| Defaults to the current directory.
    #| val_type: string
    pkgPath <- "."

    execCompile(pkgPath)
  }
)
