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
    #| short: n
    name <- NULL

    #| description: Optional boolean switch to enable verbose output.
    #| required: false
    #| val_type: string
    #| short: b
    bye <- TRUE

    #| description: Character option with default value.
    #| short: f
    #| val_type: string
    organ <- "Bioconductor"

    #| description: Numeric vector for multiple values.
    #| val_type: float
    #| short: c
    count <- c()

    #| description: List for parsed values (integers, floats, etc.).
    #| short: i
    #| val_type: integer
    indices <- list()

    ## Example usage of the parameters
    message("Hi ", name, " !")
    message("The ", organ, " team is the best !")
    message("Ready ? ", count, " ...")
    if (length(indices) > 0) {
        message("These members especially: ", paste(indices, collapse = ", "))
    }

    if (bye) {
        message("Bye bye now, ", name)
    }
  }
)
