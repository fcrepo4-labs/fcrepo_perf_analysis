if(require('ggplot2', quietly=TRUE) == FALSE){
  install.packages('ggplot2')
} else {
  print('ggplot2 already installed.')
}

# svglite requires Cairo 
#   deb: libcairo2-dev (Debian, Ubuntu)
#   brew: cairo (OSX)
if(require('svglite', quietly=TRUE) == FALSE){
  install.packages('svglite')
} else {
  print('svglite already installed.')
}