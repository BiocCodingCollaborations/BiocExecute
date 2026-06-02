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
  },

  #| name: execCompile
  #| title: Compile CLI Scripts
  #| description: Generate executable files from the R scripts located in the exec/scripts directory.
  execCompile = {

    #| description: Path to the package root.
    #| required: false
    #| val_type: string
    #| short: p
    path <- "."

    ## Execute the package function
    BiocExecute::execCompile(
        pkgPath = path
    )
  },

  #| name: execInstall
  #| title: Install CLI Executables
  #| description: Install the compiled CLI executables to a local or system bin directory.
  execInstall = {

    #| description: Package names to install.
    #| val_type: string
    #| short: p
    package <- NULL

    #| description: Destination directory for the executables, auto-detected when not set.
    #| required: false
    #| val_type: string
    #| short: d
    destdir <- NULL

    #| description: Additional library paths used to locate installed packages.
    #| required: false
    #| val_type: string
    #| short: l
    lib.loc <- NULL

    #| description: Overwrite existing launchers.
    #| required: false
    #| short: o
    overwrite <- FALSE

    ## Execute the package function
    BiocExecute::execInstall(
        package = package,
        destdir = destdir,
        lib.loc = lib.loc,
        overwrite = overwrite
    )
  },

  #| name: execSkeleton
  #| title: Scaffold CLI Skeleton
  #| description: Create the exec/ directory structure and populate it with a template.
  execSkeleton = {

    #| description: Path to the package root.
    #| required: false
    #| val_type: string
    #| short: p
    path <- "."

    ## Execute the package function
    BiocExecute::execSkeleton(
        path = path
    )
  },

  #| name: execTemplate
  #| title: Copy CLI Template
  #| description: Copy the CLI template to the scripts directory.
  execTemplate = {

    #| description: Path to the scripts directory.
    #| val_type: string
    #| short: d
    scripts_dir <- NULL

    #| description: Name of the template script, defaults to "base_template".
    #| required: false
    #| val_type: string
    #| short: n
    name <- "base_template.R"

    ## Execute the package function
    BiocExecute::execTemplate(
        scripts_dir = scripts_dir,
        name = name
    )
  },

  #| name: execUninstall
  #| title: Uninstall CLI Executables
  #| description: Uninstall the compiled CLI executables from a local or system bin directory.
  execUninstall = {

    #| description: Package names to uninstall.
    #| val_type: string
    #| short: p
    package <- NULL

    #| description: Directory containing the launchers, auto-detected when not set.
    #| required: false
    #| val_type: string
    #| short: d
    destdir <- NULL

    ## Execute the package function
    BiocExecute::execUninstall(
        package = package,
        destdir = destdir
    )
  }
)
