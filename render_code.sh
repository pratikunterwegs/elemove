#!/bin/bash

# style rmd
Rscript --vanilla --slave -e 'styler::style_dir(".", filetype = "Rmd", recursive = FALSE)'

# render books
Rscript --vanilla --slave -e 'bookdown::render_book("index.Rmd")'

# make R scripts from Rmd into the R folder
rm R/*
Rscript --vanilla --slave -e 'lapply(list.files(pattern = "(\\d{2}_)*.Rmd"), function(x) knitr::purl(x, output = sprintf("R/%s", gsub(".{4}$", ".R", x)), documentation = 2))'
rm R/index.R

# convert ipython to python
jupyter nbconvert --to python *.ipynb
mv *.py python/
