#| name: execUninstall
#| title: Uninstall CLI Executables
#| description: Uninstall the compiled CLI executables from a local or system bin directory.

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
