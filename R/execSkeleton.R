#' Scaffold a CLI skeleton for a package
#'
#' Creates \code{exec/} and \code{exec/scripts/} in the package root and
#' pulls a minimal example script into \code{exec/scripts/} before running
#' \code{execComplile}
#'
#' @param path Path to the package root. Defaults to the current working directory.
#'
#' @return Invisibly, the path to the created entry-point script.
#' @export
execSkeleton <- function(path = ".") {
    path <- normalizePath(path, mustWork = TRUE)

    exec_dir    <- file.path(path, "exec")
    scripts_dir <- file.path(exec_dir, "scripts")
    dir.create(scripts_dir, recursive = TRUE, showWarnings = FALSE)

    execTemplate(scripts_dir)

    # Run execCompile
    # execCompile()

    message("Read Rapp docs at https://github.com/r-lib/Rapp for examples.")
    message("Install to PATH by running: execInstall()")
}
