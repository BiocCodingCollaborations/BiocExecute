#| name: execInstall
#| title: Install CLI Executables
#| description: Install the compiled CLI executables to a local or system bin directory.

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