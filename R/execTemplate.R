#' Copy the CLI template to the scripts directory
#'
#' @param scripts_dir Path to the scripts directory.
#' 
#' @param name Name of the template script, defaults to "base_template"
#'
#' @return Invisibly, the path to the created template script.
#' @export
execTemplate <- function(scripts_dir, name = "base_template.R") {
  template_path <- system.file("execTemplate.txt", package = "BiocExecute")

  if (template_path == "") {
    stop("Template file 'execTemplate.txt' not found in package 'BiocExecute'.")
  }

  dest_path <- file.path(scripts_dir, name)
  file.copy(template_path, dest_path, overwrite = TRUE)
  message(sprintf("Created template file at %s", dest_path))
  invisible(dest_path)
}