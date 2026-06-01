.scriptNamePattern <- "^#\\|[[:space:]]*name:[[:space:]]*(.*)$"


.stopScript <- function(scriptPath, message) {
    stop(sprintf("%s Script: `%s`", message, scriptPath), call. = FALSE)
}


.validateScriptPath <- function(scriptPath) {
    if (!is.character(scriptPath) || length(scriptPath) != 1L ||
            is.na(scriptPath)) {
        .stopScript(scriptPath, "`scriptPath` must be a single file path.")
    }

    if (!file.exists(scriptPath) || dir.exists(scriptPath)) {
        .stopScript(scriptPath, "`scriptPath` must point to an existing file.")
    }
}


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


.validateScriptName <- function(scriptName, scriptPath) {
    if (!nzchar(scriptName) || !identical(make.names(scriptName), scriptName)) {
        .stopScript(scriptPath, "The script name must be a valid R object name.")
    }
}


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


.validatePkgPath <- function(pkgPath) {
    if (!is.character(pkgPath) || length(pkgPath) != 1L || is.na(pkgPath)) {
        stop("`pkgPath` must be a single directory path.", call. = FALSE)
    }

    if (!dir.exists(pkgPath)) {
        stop("`pkgPath` must point to an existing directory.", call. = FALSE)
    }
}


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


.scalarField <- function(value, field) {
    if (!is.character(value) || length(value) != 1L || is.na(value) ||
            !nzchar(trimws(value)) || grepl("[\r\n]", value)) {
        stop(sprintf("`%s` must be a single non-empty line.", field),
             call. = FALSE)
    }
    trimws(value)
}


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


.descriptionHeader <- function(lines) {
    if (length(lines) == 1L) {
        sprintf("#| description: %s", lines)
    } else {
        c("#| description: |", paste0("#|   ", lines))
    }
}


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


.indent <- function(lines, size) {
    ifelse(nzchar(lines), paste0(strrep(" ", size), lines), "")
}


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
