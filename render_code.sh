#!/bin/bash

# style rmd
Rscript --vanilla --slave -e 'styler::style_dir(".",filetype = "Rmd")'

# render books
Rscript --vanilla --slave -e 'bookdown::render_book("index.Rmd")'

# make R scripts from Rmd into the R folder
Rscript --vanilla --slave -e 'lapply(list.files(pattern = "(\\d{2}_)"), function(x) knitr::purl(x, output = sprintf("R/%s", gsub(".{4}$", ".R", x)), documentation = 2))'
