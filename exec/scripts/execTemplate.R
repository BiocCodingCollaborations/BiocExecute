#| name: execTemplate
#| title: Copy CLI Template
#| description: Copy the CLI template to the scripts directory.

#| description: Path to the scripts directory.
#| val_type: string
scripts_dir <- NULL

#| description: Name of the template script, defaults to "base_template".
#| required: false
#| val_type: string
name <- "base_template.R"

## Execute the package function
BiocExecute::execTemplate(
    scripts_dir = scripts_dir,
    name = name
)