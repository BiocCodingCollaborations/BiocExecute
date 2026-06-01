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

