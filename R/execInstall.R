#' Install CLI launchers for package executables
#'
#' Install command-line launchers for the executable scripts provided by one or
#' more installed R packages. This is a convenience wrapper around
#' [Rapp::install_pkg_cli_apps()].
#'
#' @param package Package names to process.
#' @param destdir Directory where launchers are written. When `NULL`, Rapp
#' determines the installation directory. See [Rapp::install_pkg_cli_apps()] for
#' information about the defaults directories.
#' @param lib.loc Additional library paths used to locate installed packages.
#' @param overwrite Whether existing launchers should be replaced. 
#'
#' @return Invisibly returns the paths of launchers written by
#' [Rapp::install_pkg_cli_apps()].
#'
#' @seealso [Rapp::install_pkg_cli_apps()], [execUninstall()]
#'
#' @export
execInstall <- function(package, destdir = NULL, lib.loc = NULL,
                        overwrite = NA) {
    Rapp::install_pkg_cli_apps(
        package = package,
        destdir = destdir,
        lib.loc = lib.loc,
        overwrite = overwrite
    )
}


#' Uninstall CLI launchers for package executables
#'
#' Remove command-line launchers previously installed for one or more R
#' packages. This is a convenience wrapper around
#' [Rapp::uninstall_pkg_cli_apps()].
#'
#' @param package Package names to process.
#' @param destdir Directory containing the launchers. When `NULL`, Rapp
#' determines the installation directory. See [Rapp::install_pkg_cli_apps()] for
#' information about the defaults directories.
#'
#' @return Invisibly returns the paths of launchers removed by
#' [Rapp::uninstall_pkg_cli_apps()].
#'
#' @seealso [Rapp::uninstall_pkg_cli_apps()], [execInstall()]
#'
#' @export
execUninstall <- function(package, destdir = NULL) {
    Rapp::uninstall_pkg_cli_apps(
        package = package,
        destdir = destdir
    )
}
