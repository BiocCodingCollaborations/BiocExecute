#| name: execUninstall
#| title: Uninstall CLI Executables
#| description: Uninstall the compiled CLI executables to a local or system bin directory.

#| description: Package names to uninstall
#| required: false
#| val_type: string
#| short: p
package <- "."

#| description: Directory containing the launchers, if NULL tries to auto-detects
#| required: false
#| val_type: string
#| short: b
destdir <- "~/.local/bin"

## Execute the package function
BiocExecute::execUninstall(
    package = package,
    destdir = destdir
)