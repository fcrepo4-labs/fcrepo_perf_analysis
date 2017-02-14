require('knitr')
require('rmarkdown')
require('ggplot2')

# Get command line args entered by the user
options <- commandArgs(TRUE)

# Get name of directory with build artifacts (reports)
if(length(options)==0) {
  artifacts_dir <- './build'
}else{
  artifacts_dir <- options[1]
}

rmarkdown::render("31-github-report.rmd", params = list(input_dir = artifacts_dir),
                  output_file="report.md", output_dir=artifacts_dir)
                
