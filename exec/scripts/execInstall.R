#| name: execInstall
#| title: Install CLI Executables
#| description: Install the compiled CLI executables to a local or system bin directory.

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
