.scriptNamePattern <- "^#\\|[[:space:]]*name:[[:space:]]*(.*)$"


#' Stop with a script-specific error
#'
#' @param scriptPath A path identifying the script that caused the error.
#' @param message The error message.
#'
#' @return This function does not return anything.
#'
#' @keywords internal
#' @noRd
.stopScript <- function(scriptPath, message) {
    stop(sprintf("%s Script: `%s`", message, scriptPath), call. = FALSE)
}


#' Validate a script path
#'
#' @param scriptPath A path to an R script.
#'
#' @return Invisibly returns `NULL` when the path is valid.
#'
#' @keywords internal
#' @noRd
.validateScriptPath <- function(scriptPath) {
    if (!is.character(scriptPath) || length(scriptPath) != 1L ||
            is.na(scriptPath)) {
        .stopScript(scriptPath, "`scriptPath` must be a single file path.")
    }

    if (!file.exists(scriptPath) || dir.exists(scriptPath)) {
        .stopScript(scriptPath, "`scriptPath` must point to an existing file.")
    }
}


#' Read a BiocExecute script
#'
#' @param scriptPath A path to an R script.
#'
#' @return A character vector containing the script lines.
#'
#' @keywords internal
#' @noRd
.readScript <- function(scriptPath) {
    script <- tryCatch(
        readLines(scriptPath, warn = FALSE),
        error = function(error) .stopScript(scriptPath, conditionMessage(error))
    )
    if (!length(script)) {
        .stopScript(scriptPath, "The script is empty.")
    }

    if (grepl("^#!", script[[1L]])) {
        .stopScript(
            scriptPath,
            "To be used with BiocExecute, the script should not contain any `#!` header, please remove it."
        )
    }

    script
}


#' Split a script into its header and content
#'
#' @param script A character vector containing the script lines.
#'
#' @return A list with `header` and `content` elements.
#'
#' @keywords internal
#' @noRd
.splitScript <- function(script) {
    headerEnd <- match(FALSE, grepl("^#\\|", script),
                       nomatch = length(script) + 1L) - 1L

    ## Keep the optional Rapp header lines
    headerLines <- if (headerEnd) script[seq_len(headerEnd)] else character()

    ## Keep the rest of the script unchanged
    contentStart <- headerEnd + 1L
    content <- if (contentStart <= length(script)) {
        script[contentStart:length(script)]
    } else {
        character()
    }

    list(header = headerLines, content = content)
}


#' Extract a script name from a header
#'
#' @param header A character vector containing Rapp annotation lines.
#' @param scriptPath A path identifying the parsed script.
#'
#' @return The script name, or `NULL` when the header has no `name` field.
#'
#' @keywords internal
#' @noRd
.extractScriptName <- function(header, scriptPath) {
    nameLines <- grep(.scriptNamePattern, header, value = TRUE)
    if (length(nameLines) > 1L) {
        .stopScript(
            scriptPath,
            "The script header must not define more than one name."
        )
    }
    if (!length(nameLines)) {
        return(NULL)
    }

    trimws(sub(.scriptNamePattern, "\\1", nameLines))
}


#' Validate a script name
#'
#' @param scriptName The script name to validate.
#' @param scriptPath A path identifying the parsed script.
#'
#' @return Invisibly returns `NULL` when the name is valid.
#'
#' @keywords internal
#' @noRd
.validateScriptName <- function(scriptName, scriptPath) {
    if (!nzchar(scriptName) || !identical(make.names(scriptName), scriptName)) {
        .stopScript(scriptPath, "The script name must be a valid R object name.")
    }
}


#' Parse a BiocExecute script
#'
#' Read an R script and separate its optional Rapp annotation header from its
#' executable content.
#'
#' The header consists of consecutive `#|` annotation lines at the beginning
#' of the file. It may contain a `name` field, but this field is optional. When
#' present, the name must be defined only once and must be a valid R object
#' name. A script must not start with a `#!` header because the compiled
#' executable provides its own Rapp shebang.
#'
#' @param scriptPath A path to the R script to parse.
#'
#' @return A list with two character-vector elements:
#' \describe{
#'   \item{header}{The optional leading `#|` annotation lines.}
#'   \item{content}{The remaining script lines, preserved unchanged.}
#' }
#'
#' @examples
#' script <- tempfile(fileext = ".R")
#' writeLines(c("#| name: example", "", "value <- 1"), script)
#' scriptParser(script)
#' unlink(script)
#'
#' @export
scriptParser <- function(scriptPath) {
    ## Check that the input is a readable script
    .validateScriptPath(scriptPath)
    script <- .readScript(scriptPath)

    ## Split the optional Rapp header from the script content
    parsedScript <- .splitScript(script)

    ## Check the script name when it is provided
    scriptName <- .extractScriptName(parsedScript$header, scriptPath)
    if (!is.null(scriptName)) {
        .validateScriptName(scriptName, scriptPath)
    }

    parsedScript
}


#' Validate a package path
#'
#' @param pkgPath A path to an R package directory.
#'
#' @return Invisibly returns `NULL` when the path is valid.
#'
#' @keywords internal
#' @noRd
.validatePkgPath <- function(pkgPath) {
    if (!is.character(pkgPath) || length(pkgPath) != 1L || is.na(pkgPath)) {
        stop("`pkgPath` must be a single directory path.", call. = FALSE)
    }

    if (!dir.exists(pkgPath)) {
        stop("`pkgPath` must point to an existing directory.", call. = FALSE)
    }
}


#' Find package scripts
#'
#' @param pkgPath A path to an R package directory.
#'
#' @return A character vector containing paths to the R scripts.
#'
#' @keywords internal
#' @noRd
.findScripts <- function(pkgPath) {
    scriptsPath <- file.path(pkgPath, "exec", "scripts")
    if (!dir.exists(scriptsPath)) {
        stop("The package must contain an `exec/scripts` directory.",
             call. = FALSE)
    }

    list.files(
        scriptsPath,
        pattern = "\\.[Rr]$",
        full.names = TRUE
    )
}


#' Read package metadata fields
#'
#' @param pkgPath A path to an R package directory.
#'
#' @return A character matrix containing the package, title, and description.
#'
#' @keywords internal
#' @noRd
.readPackageFields <- function(pkgPath) {
    descriptionPath <- file.path(pkgPath, "DESCRIPTION")
    if (!file.exists(descriptionPath) || dir.exists(descriptionPath)) {
        stop("The package must contain a `DESCRIPTION` file.", call. = FALSE)
    }

    packageFields <- tryCatch(
        read.dcf(
            descriptionPath,
            fields = c("Package", "Title", "Description")
        ),
        error = function(error) {
            stop(conditionMessage(error), call. = FALSE)
        }
    )
    if (nrow(packageFields) != 1L || anyNA(packageFields) ||
            any(!nzchar(trimws(packageFields)))) {
        stop(
            "The package `DESCRIPTION` must define Package, Title and Description fields.",
            call. = FALSE
        )
    }

    packageFields
}


#' Validate and normalize a scalar metadata field
#'
#' @param value The metadata field value.
#' @param field The field name to include in error messages.
#'
#' @return A trimmed character scalar.
#'
#' @keywords internal
#' @noRd
.scalarField <- function(value, field) {
    if (!is.character(value) || length(value) != 1L || is.na(value) ||
            !nzchar(trimws(value)) || grepl("[\r\n]", value)) {
        stop(sprintf("`%s` must be a single non-empty line.", field),
             call. = FALSE)
    }
    trimws(value)
}


#' Normalize a package description
#'
#' @param value The package description.
#'
#' @return A character vector containing the description lines.
#'
#' @keywords internal
#' @noRd
.descriptionField <- function(value) {
    if (!is.character(value) || !length(value) || anyNA(value)) {
        stop("`description` must contain one or more lines.",
             call. = FALSE)
    }
    lines <- strsplit(paste(value, collapse = "\n"), "\n",
                      fixed = TRUE)[[1L]]
    lines <- sub("\r$", "", lines)
    if (!length(lines) || !any(nzchar(trimws(lines)))) {
        stop("`description` must contain one or more non-empty lines.",
             call. = FALSE)
    }
    lines
}


#' Format a description as Rapp annotations
#'
#' @param lines A character vector containing description lines.
#'
#' @return A character vector containing `#| description` annotation lines.
#'
#' @keywords internal
#' @noRd
.descriptionHeader <- function(lines) {
    if (length(lines) == 1L) {
        sprintf("#| description: %s", lines)
    } else {
        c("#| description: |", paste0("#|   ", lines))
    }
}


#' Normalize package metadata
#'
#' @param packageFields A character matrix returned by `.readPackageFields()`.
#'
#' @return A list containing the package `name`, `title`, and `description`.
#'
#' @keywords internal
#' @noRd
.packageMetadata <- function(packageFields) {
    packageName <- .scalarField(packageFields[1L, "Package"], "name")
    if (grepl("[/\\\\]", packageName)) {
        stop("`name` must not contain path separators.", call. = FALSE)
    }
    list(
        name = packageName,
        title = .scalarField(packageFields[1L, "Title"], "title"),
        description = .descriptionField(packageFields[1L, "Description"])
    )
}


#' Determine compiled command names
#'
#' @param parsedScripts A list of parsed scripts.
#' @param scripts A character vector containing the corresponding script paths.
#'
#' @return A character vector containing unique, valid R object names.
#'
#' @keywords internal
#' @noRd
.commandNames <- function(parsedScripts, scripts) {
    commandNames <- vapply(
        seq_along(parsedScripts),
        function(index) {
            commandName <- .extractScriptName(
                parsedScripts[[index]]$header,
                scripts[[index]]
            )
            if (is.null(commandName)) {
                commandName <- tools::file_path_sans_ext(
                    basename(scripts[[index]])
                )
            }
            .validateScriptName(commandName, scripts[[index]])
            commandName
        },
        character(1)
    )
    if (anyDuplicated(commandNames)) {
        duplicatedName <- commandNames[duplicated(commandNames)][[1L]]
        stop(
            sprintf("Script names must be unique. Duplicated name: `%s`.",
                    duplicatedName),
            call. = FALSE
        )
    }
    commandNames
}


#' Indent non-empty lines
#'
#' @param lines A character vector containing text lines.
#' @param size The number of spaces to prepend.
#'
#' @return The indented character vector.
#'
#' @keywords internal
#' @noRd
.indent <- function(lines, size) {
    ifelse(nzchar(lines), paste0(strrep(" ", size), lines), "")
}


#' Compile script switch branches
#'
#' @param parsedScripts A list of parsed scripts.
#' @param commandNames A character vector containing command names.
#'
#' @return A character vector containing the formatted switch branches.
#'
#' @keywords internal
#' @noRd
.compileBranches <- function(parsedScripts, commandNames) {
    unlist(
        lapply(
            seq_along(parsedScripts),
            function(index) {
                branch <- c(
                    .indent(parsedScripts[[index]]$header, 2L),
                    sprintf("  %s = {", commandNames[[index]]),
                    .indent(parsedScripts[[index]]$content, 4L),
                    paste0("  }", if (index < length(parsedScripts)) "," else "")
                )
                if (index < length(parsedScripts)) c(branch, "") else branch
            }
        ),
        use.names = FALSE
    )
}


#' Write a compiled executable
#'
#' @param pkgPath A path to an R package directory.
#' @param packageMetadata A list containing package metadata.
#' @param branches A character vector containing formatted switch branches.
#'
#' @return Invisibly returns the path to the generated executable.
#'
#' @keywords internal
#' @noRd
.writeExec <- function(pkgPath, packageMetadata, branches) {
    execPath <- file.path(pkgPath, "exec")
    if (!dir.exists(execPath) &&
            !dir.create(execPath, recursive = TRUE)) {
        stop("Failed to create the package `exec` directory.", call. = FALSE)
    }

    exec <- file.path(execPath, paste0(packageMetadata$name, ".R"))
    writeLines(
        c(
            "#!/usr/bin/env Rapp",
            sprintf("#| name: %s", packageMetadata$name),
            sprintf("#| title: %s", packageMetadata$title),
            .descriptionHeader(packageMetadata$description),
            "",
            "switch(",
            '  "",',
            "",
            branches,
            ")"
        ),
        exec,
        useBytes = TRUE
    )

    invisible(exec)
}


#' Compile package scripts into a Rapp executable
#'
#' Collect the R scripts stored in a package's `exec/scripts` directory and
#' combine them into one Rapp executable containing a `switch()` entry for each
#' script.
#'
#' The generated executable metadata is read from the package `DESCRIPTION`
#' file. For each script, the switch entry uses the optional `#| name:` header
#' field when present. Otherwise, it uses the script filename without its
#' extension. Every resulting command name must be unique and must be a valid R
#' object name.
#'
#' The resulting file is written to `exec/<Package>.R`, where `<Package>` is
#' the package name from `DESCRIPTION`. File permissions are left unchanged.
#'
#' @param pkgPath A path to the R package directory. Defaults to the current
#' directory.
#'
#' @return Invisibly returns the path to the generated executable. Returns
#' `character()` invisibly when `exec/scripts` contains no R scripts.
#'
#' @examples
#' \dontrun{
#' compileExecs(".")
#' }
#'
#' @export
compileExecs <- function(pkgPath = ".") {
    .validatePkgPath(pkgPath)
    scripts <- .findScripts(pkgPath)
    if (!length(scripts)) {
        return(invisible(character()))
    }

    ## Parse every script before writing any executable
    parsedScripts <- lapply(scripts, scriptParser)
    packageFields <- .readPackageFields(pkgPath)
    packageMetadata <- .packageMetadata(packageFields)
    commandNames <- .commandNames(parsedScripts, scripts)
    branches <- .compileBranches(parsedScripts, commandNames)
    .writeExec(pkgPath, packageMetadata, branches)
}
