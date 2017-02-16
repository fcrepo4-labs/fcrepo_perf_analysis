# Pre-process fcrepo4-jemeter csv file.
#  Check header for expected fields.

# Get command line args entered by the user
options <- commandArgs(TRUE)

# If not given a file name, assume the input is stdin
if(length(options)==0) {
  input_filename <- "stdin"
}else{
  input_filename <- options[1]
}

input_file <- file(input_filename)
open(input_file, blocking=TRUE)

# Check that the header is as expected 
expected_fields <- c("timeStamp","elapsed","label","responseCode","responseMessage","threadName","dataType","success","bytes",
                    "grpThreads","allThreads","Latency")
expected_field_count <- length(expected_fields)
header_line <- readLines(input_file,n=1)
header_fields <- unlist(strsplit(header_line,","))

cat("Header check:\n")
cat("Expected:", expected_field_count, "encountered:", length(header_fields),"\n")
if(length(header_fields) != expected_field_count){
  print("Unexpected number of input fields!")
  close(input_file)
  quit(save="no", status=10)
}
  
close(input_file)