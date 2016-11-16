# Pre-process fcrepo4-jemeter csv file.
#  Check header for expected fields.

# Get command line args entered by the user
options <- commandArgs(TRUE)

# If not given a file name, assume the input is stdin
if(length(options)==0) {
  input_filename <- 'stdin'
}else{
  input_filename <- options[0]
}

input_file <- file(input_filename)
open(input_file, blocking=TRUE)

# Check that the header is as expected 
expected_fields <- c('timeStamp','elapsed','label','responseCode','responseMessage','threadName','dataType','success','bytes',
                    'grpThreads','allThreads','Latency')
header_line <- readLines(input_file,n=1)
header_fields <- unlist(strsplit(header_line,','))

if(length(header_fields) != length(expected_fields) || any(header_fields != expected_fields)){
  print('Headers DO NOT match expected fields!')
  print('expected_fields')
  print(expected_fields)
  print('header_line')
  print(header_line)
  print('header_fields')
  print(header_line)
  
  close(input_file)
  quit(save='no', status=10)
}else{
  print('Headers MATCH expected fields.')
}

close(input_file)