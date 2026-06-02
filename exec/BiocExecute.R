#!/usr/bin/env Rapp
#| name: BiocExecute
#| title: Make package functions or workflows executable in the command line.
#| description: |
#|   The BiocExecute package should be used by a package maintainer
#|   that wants to make his/her package functions and/or workflows executable in
#|   the command line.

switch(
  "",

  #| name: execCompile
  #| title: Compile CLI Scripts
  #| description: Generate executable files from the R scripts located in the exec/scripts directory.
  execCompile = {

    #| description: Path to the package root.
    #| required: false
    #| val_type: string
    path <- "."

    ## Execute the package function
    BiocExecute::execCompile(
        path = path
    )
  },

  #| name: execInstall
  #| title: Install CLI Executables
  #| description: Install the compiled CLI executables to a local or system bin directory.
  execInstall = {

    #| description: Path to the package root.
    #| required: false
    #| val_type: string
    path <- "."

    #| description: Destination directory for the executables (e.g., ~/.local/bin).
    #| required: false
    #| val_type: string
    bin <- "~/.local/bin"

    ## Execute the package function
    BiocExecute::execInstall(
        path = path,
        bin = bin
    )
  },

  #| name: execSkeleton
  #| title: Scaffold CLI Skeleton
  #| description: Create the exec/ directory structure and populate it with a template.
  execSkeleton = {

    #| description: Path to the package root.
    #| required: false
    #| val_type: string
    path <- "."

    ## Execute the package function
    BiocExecute::execSkeleton(
        path = path
    )
  },

  #| name: execTemplate
  #| title: Copy CLI Template
  #| description: Copy the BiocExecute CLI template script to a specified 
  #|   directory.
  execTemplate = {

    #| description: Path to the scripts directory where the template will be copied.
    #| val_type: string
    scripts_dir <- NULL

    #| description: The filename for the new template script.
    #| required: false
    #| val_type: string
    name <- "base_template.R"

    ## Execute the package function
    BiocExecute::execTemplate(
        scripts_dir = scripts_dir,
        name = name
    )
  }
)
