#| name: execTemplate
#| title: Copy CLI Template
#| description: Copy the BiocExecute CLI template script to a specified 
#|   directory.

#| description: Path to the scripts directory where the template will be copied.
#| val_type: string
scripts_dir <- NULL

#| description: The filename for the new template script.
#| required: false
#| val_type: string
name <- "base_template.R"

## Execute the package function
BiocExecute::execTemplate(
    scripts_dir = scripts_dir,
    name = name
)