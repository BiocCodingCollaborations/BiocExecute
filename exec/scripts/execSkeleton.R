#| name: execSkeleton
#| title: Scaffold CLI Skeleton
#| description: Create the exec/ directory structure and populate it with a template.

#| description: Path to the package root.
#| required: false
#| val_type: string
#| short: p
path <- "."

## Execute the package function
BiocExecute::execSkeleton(
    path = path
)