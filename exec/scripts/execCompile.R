#| name: execCompile
#| title: Compile package scripts into a Rapp executable
#| description:
#| Collect the R scripts stored in a package's ‘exec/scripts’
#| directory and combine them into one Rapp executable
#| containing a ‘switch()’ entry for each script.

#| description: A path to the R package directory.
#| Defaults to the current directory.
#| val_type: string
pkgPath <- "."

execCompile(pkgPath)
