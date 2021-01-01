#!/bin/bash

# to build the docker image from rocker/r-base
sudo docker build -t pratik/elemove .

# to run the docker
sudo docker run --rm -v ./figures:/figures pratik/elemove
