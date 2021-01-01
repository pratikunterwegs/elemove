# Base image https://hub.docker.com/u/rocker/
FROM rocker/tidyverse

# Maintainer info
LABEL MAINTAINER key="Pratik Gupte <pratikgupte16@gmail.com>"

## Install extra R packages using requirements.R
## Specify requirements as R install commands e.g.
## 
## install.packages("<myfavouritepacakge>") or
## devtools::install("SymbolixAU/googleway")
ENV RENV_VERSION 0.12.3

## Copy requirements.R to container directory /tmp
# COPY ./DockerConfig/requirements.R /tmp/requirements.R 
## install required libs on container
# RUN Rscript /tmp/requirements.R

# Set up renv
RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"

# try to get renv again
WORKDIR /
COPY renv.lock renv.lock
RUN R -e 'renv::restore()'

# create an R user

## Copy your working files over
## The $USER defaults to `rstudio` but you can change this at runtime
COPY ./data /data
COPY ./R /R

# make local dirs
RUN mkdir -p /figures

RUN Rscript R/02_plot_code.R

RUN echo "done"
