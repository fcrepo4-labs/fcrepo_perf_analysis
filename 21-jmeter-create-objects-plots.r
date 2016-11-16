require('ggplot2')
require('svglite')

options <- commandArgs(TRUE)

# If not given a file name, assume the input is stdin so the data can be piped in.
if(length(options)==0) {
  input_filename <- 'stdin'
}else{
  input_filename <- options[0]
}

### Read file passed as command line arg or piped in
#   Expected Headers ('label','elapsed',target_columns)
input_file <- file(input_filename)
open(input_file, blocking=TRUE)

df <- read.csv(input_file)
close(input_file)

### Get names of target columns
target_column_names <- setdiff(colnames(df), c('elapsed','label'))# Simple linear regression model to answer:

### Plot each 

#  Given the data, what is our model of elapsed time as predicted by the variable of interest?
make_linear_model <- function(column_label, input_data){
  lm_formula <- as.formula(paste('elapsed ~', column_label))
  lmodel <- glm(lm_formula, data=input_data, na.action=na.omit)
}
glmodels <- lapply(target_column_names, FUN=make_linear_model, df)

# Create a dot plot with the linear model plotted as a line
make_dot_plot <- function(column_label, input_data){
  p <- ggplot(input_data, aes_string(x=column_label, y='elapsed')) +
    geom_point(shape=1) +
    stat_smooth(method="glm", color="red")
}
dot_plots <- lapply(target_column_names, FUN=make_dot_plot, df)

# Create binned 2d plot to reduce number of points plotted
make_bin_plot <- function(column_label, input_data){
  p <- ggplot(input_data, aes_string(x=column_label, y='elapsed')) +
    geom_bin2d()
}
bin_plots <- lapply(target_column_names, FUN=make_bin_plot, df)

# Write plots to file
for(i in 1:length(dot_plots)){
  png_filename <- paste("reports/21-","dot-",bin_plots[[1]]$label$x,".png", sep="") 
  svg_filename <- paste("reports/21-","dot-",bin_plots[[1]]$label$x,".svg", sep="") 
  ggsave(png_filename,plot=dot_plots[[i]],device="png")
  ggsave(svg_filename,plot=dot_plots[[i]],device="svg")
}

for(i in 1:length(bin_plots)){
  png_filename <- paste("reports/21-","bin-",bin_plots[[1]]$label$x,".png", sep="") 
  svg_filename <- paste("reports/21-","bin-",bin_plots[[1]]$label$x,".svg", sep="") 
  ggsave(png_filename,plot=bin_plots[[i]],device="png")
  ggsave(svg_filename,plot=bin_plots[[i]],device="svg")
}