#| name: execCompile
#| title: Compile CLI Scripts
#| description: Generate executable files from the R scripts located in the exec/scripts directory.

#| description: Path to the package root.
#| required: false
#| val_type: string
path <- "."

## Execute the package function
BiocExecute::execCompile(
    path = path
)