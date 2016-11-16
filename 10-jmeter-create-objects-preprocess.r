# Pre-Process fcrepo4-jemeter csv file.
# Select a subset of the entire dataset.

# Get command line args entered by the user
options <- commandArgs(TRUE)

# If not given a file name, assume the input is stdin so the data can be piped in.
if(length(options)==0) {
  input_filename <- 'stdin'
}else{
  input_filename <- options[1]
}

##
### Read file passed as command line arg or piped in
#   Expected Headers
#     ('timeStamp','elapsed','label','responseCode','responseMessage',
#      'threadName','dataType','success','bytes', 'grpThreads','allThreads','Latency')
input_file <- file(input_filename)
open(input_file, blocking=TRUE)

df <- read.csv(input_file)
close(input_file)

##
### DEFINE LABELS of INTEREST (target_labels)
#     e.g. if targeting "Create" events, find all the factors of the label column that start with "Create"

# Get 'label' factor levels that start with Create. These are the target for this analysis. 
target_labels = grep('^Create', levels(df[,'label']), value=TRUE)

# Make column names that correspond to these labels:
target_column_names <- gsub('^Create', 'num', target_labels)
target_column_names <- chartr(' ', '_', target_column_names)

# Make a mask vectors to filter for rows that are for the target label and were successful
make_mask_from_label <- function(x, data){ 
  data[,'label'] == x & data[,'success'] == 'true'
}
target_success_masks <- lapply(target_labels, FUN=make_mask_from_label, df)
for(i in target_labels){
   df[,'label'] == target_labels[i] & df[,'success'] == 'true'
}

# For each target label, do a cumulative sum of the successes and add column to data frame.  
#  i.e. cumulative sum of the number of previous matches of the label where success was 'true'
#  Each row will have the number of previous successful creates|gets|deletes or whatever the target is.
for(i in seq(1, length(target_labels))){
  df[,target_column_names[i]] <- cumsum(unlist(target_success_masks[i]))
}

##
### Make summary of time elapsed for each target label

# Summaries of the response (dependent) variable for the rows of each target variable
#   e.g. summary of elapsed for Create Object rows, or summary of elapsed for Create Binary Resource rows
make_summary <- function(column_label, row_mask, input_data){
  summary(input_data[row_mask,'elapsed'])
}
summaries <- mapply(FUN=make_summary, target_column_names, target_success_masks, MoreArgs=list(input_data=df), SIMPLIFY=FALSE )

# Print results of analysis to file in results directory
report_dir = './reports'
dir.create(report_dir, showWarnings=FALSE, mode='0664')
if(dir.exists(report_dir)){
  outfile <- file(paste(report_dir, '10-create-objects-summaries.txt', sep='/'))
  # start sinking output to file (alternatively could use cat)
  sink(file=outfile, type=c('output') )
  print('Time Elapsed Summaries')
  print(summaries)
  # stop sinking output to file
  sink(file=NULL)
  close(outfile)
}

##
### Do subsetting and subsampling of data set. Write subset to console.

# Sample at every 25th success for each target column.
make_subset <- function(target_column_name, row_mask, input_data){
  base_columns <- c('label','elapsed')
  subsample_mask <- row_mask & df[,target_column_name] %% 25 == 0
  return( df[subsample_mask, c(base_columns, target_column_name)] )
}
subsets <- mapply(FUN=make_subset, target_column_names, target_success_masks, MoreArgs=(list(input_data=df)), SIMPLIFY=FALSE)

# Merge all the subsets.
merged_frame <- Reduce(function(...) merge(..., all=TRUE), subsets)

# Print the subset as csv.
write.csv(merged_frame, row.names=FALSE)


