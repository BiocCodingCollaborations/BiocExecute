#' Install CLI launchers for package executables
#'
#' Install command-line launchers for the executable scripts provided by one or
#' more installed R packages. This is a convenience wrapper around
#' [Rapp::install_pkg_cli_apps()].
#'
#' @param package A `character` vector containing package names to process.
#' @param destdir A `character` scalar giving the directory where launchers are
#' written, or `NULL`. When `NULL`, Rapp determines the installation directory.
#' See [Rapp::install_pkg_cli_apps()] for information about the default
#' directories.
#' @param lib.loc A `character` vector containing additional library paths used to
#' locate installed packages, or `NULL`.
#' @param overwrite A `logical` scalar indicating whether existing launchers
#' should be replaced. Use `NA` to let Rapp prompt interactively and otherwise
#' skip existing non-Rapp executables.
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
#' @param package A `character` vector containing package names to process.
#' @param destdir A `character` scalar giving the directory containing the
#' launchers, or `NULL`. When `NULL`, Rapp determines the installation
#' directory. See [Rapp::install_pkg_cli_apps()] for information about the
#' default directories.
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
