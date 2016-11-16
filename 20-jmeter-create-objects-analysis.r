# Use subset of fcrepo4-jemeter data for statistical analysis.
#   How does the elapsed time correlate with the number of target successes?
#   How much of the elapsed time does the number of target successes explain?
# e.g. "How does the elapsed time correlate with the number of Create Object successes? 
#      "How much of the variation in the elapsed time is explained by the number of Create Object successes? 

options <- commandArgs(TRUE)

# If not given a file name, assume the input is stdin so the data can be piped in.
if(length(options)==0) {
  input_filename <- 'stdin'
}else{
  input_filename <- options[1]
}

### Read file passed as command line arg or piped in
#   Expected Headers ('label','elapsed',target_columns)
input_file <- file(input_filename)
open(input_file, blocking=TRUE)

df <- read.csv(input_file)
close(input_file)

### Get names of target columns
target_column_names <- setdiff(colnames(df), c('elapsed','label'))

# Pearson's correlation coefficient with the assumption 
#   that the elapsed time should be increasing. 
make_elapsed_correlation <- function(column_label, input_data){
  cor_formula <- as.formula(paste('~ elapsed +', column_label))
  result <- cor.test(cor_formula, alternative="greater", data=input_data, na.action=na.omit)
  return(result)
}
cor_results <- lapply(target_column_names, FUN=make_elapsed_correlation, df)

# Simple linear regression model to answer:
#  how much of the variation in the elapsed time can be accounte for by the variable of interest?
make_linear_model <- function(column_label, input_data){
  lm_formula <- as.formula(paste('elapsed ~', column_label))
  lmodel <- lm(lm_formula, data=input_data, na.action=na.omit)
}
lmodels <- lapply(target_column_names, FUN=make_linear_model, df)

# Print results of analysis to file in results directory
report_dir = './reports'
dir.create(report_dir, showWarnings=FALSE, mode='0664')
if(dir.exists(report_dir)){
  outfile <- file(paste(report_dir, '20-create-objects-stats.txt', sep='/'))
  # start sinking output to file (alternatively could use cat)
  sink(file=outfile, type=c('output') )
  print('Correlation Results')
  print(cor_results)
  print('Linear Regression Models')
  print(lmodels)
  # stop sinking output to file
  sink(file=NULL)
  close(outfile)
}
