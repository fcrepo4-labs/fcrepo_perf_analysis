require('knitr')
require('rmarkdown')
require('ggplot2')
library('tools')

# Get command line args entered by the user
options <- commandArgs(TRUE)

# Get name of input directory with build artifacts (reports)
if(length(options)==0) {
  artifacts_dir <- './build'
}else{
  artifacts_dir <- options[1]
}

# Get name of output
if(length(options) < 2){
  output_name <- 'report.md'
}else{
  output_name <- options[2]  
}

dir.create(artifacts_dir, showWarnings=FALSE, mode='0664')

rmarkdown::render("31-github-report.rmd", params = list(input_dir = artifacts_dir, output_name = output_name),
                  output_file=output_name)

# Get the basename of the report output  
report_name <- file_path_sans_ext( basename(output_name) )

# Move resulting report into artifacts directory
# Move primary file
file.rename(output_name, file.path(artifacts_dir, output_name))
# if extant, move the html preview as well
html_preview <- paste0(report_name,'.html')
if( file.exists(html_preview) ){
  file.rename(html_preview, file.path(artifacts_dir, html_preview))
}

# Move resulting imgages directory into artifacts directory
imgs_dirname <- paste0(report_name,"_files")
file.rename(imgs_dirname, file.path(artifacts_dir, imgs_dirname))

