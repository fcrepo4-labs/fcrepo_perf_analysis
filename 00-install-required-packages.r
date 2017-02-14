if(require('ggplot2', quietly=TRUE) == FALSE){
  install.packages('ggplot2')
} else {
  print('ggplot2 already installed.')
}

if(require('knitr', quietly=TRUE) == FALSE){
  install.packages('knitr', dependencies = TRUE)
} else {
  print('knitr already installed.')
}

if(require('rmarkdown', quietly=TRUE) == FALSE){
  install.packages('rmarkdown')
} else {
  print('rmarkdown already installed.')
}

# svglite requires Cairo 
#   deb: libcairo2-dev (Debian, Ubuntu)
#   brew: cairo (OSX)
if(require('svglite', quietly=TRUE) == FALSE){
  install.packages('svglite')
} else {
  print('svglite already installed.')
}