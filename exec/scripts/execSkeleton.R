#| name: execSkeleton
#| title: Scaffold CLI Skeleton
#| description: Create the exec/ directory structure and populate it with a template.

#| description: Path to the package root.
#| required: false
#| val_type: string
path <- "."

## Execute the package function
BiocExecute::execSkeleton(
    path = path
)