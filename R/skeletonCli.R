#' Scaffold a CLI skeleton for a package
#'
#' Creates \code{exec/} and \code{exec/scripts/} in the package root and
#' writes a minimal Rapp entry-point script.
#'
#' @param path Path to the package root. Defaults to the current working directory.
#'
#' @return Invisibly, the path to the created entry-point script.
#' @export
skeletonCli <- function(path = ".") {
    path <- normalizePath(path, mustWork = TRUE)

    exec_dir    <- file.path(path, "exec")
    scripts_dir <- file.path(exec_dir, "scripts")
    dir.create(scripts_dir, recursive = TRUE, showWarnings = FALSE)

    pkg_name  <- .read_pkg_name(path)
    main_file <- file.path(exec_dir, paste0(pkg_name, ".R"))

    writeLines(.main_script(pkg_name), main_file)
    Sys.chmod(main_file, "755")

    message("Created:\n  ", main_file)
    message("Read Rapp docs at https://github.com/r-lib/Rapp for examples.")
    invisible(main_file)
}

.read_pkg_name <- function(path) {
    desc <- file.path(path, "DESCRIPTION")
    if (!file.exists(desc)) return("MyPackage")
    tryCatch(
        as.character(read.dcf(desc, fields = "Package")[1L]),
        error = function(e) "MyPackage"
    )
}

.main_script <- function(pkg_name) {
    c(
        "#!/usr/bin/env Rapp",
        sprintf("#| name: %s", pkg_name),
        "#| title: Replace with a short title",
        "#| description: |",
        "#|   Replace with a description of what this tool does.",
        "",
        "#| description: Input .rds file",
        "input <- NULL",
        "",
        "#| description: Output .rds file path",
        "output <- NULL",
        "",
        sprintf("library(%s)", pkg_name),
        "",
        "obj <- readRDS(input)",
        "",
        "# Implement workflow",
        "# --OR--",
        "# Write sub scripts into exec/scripts/",
        "#   and call the compiler function",
        "obj <- foo(bar(obj))",
        "",
        "saveRDS(obj, output)",
        'message("Done. Saved to: ", output)'
    )
}
