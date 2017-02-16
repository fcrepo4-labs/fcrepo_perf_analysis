require('knitr')
require('rmarkdown')
require('ggplot2')

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
                  output_file=output_name, output_dir=artifacts_dir)