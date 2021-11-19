FROM ubuntu:latest

##### cube:v01 #####
# - Install R

## Update repos
RUN apt-get update && apt-get upgrade -y

## Assign timezone
ENV TZ=Europe/Amsterdam
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

## Prerequisites (to install repos over https)
RUN apt-get install -y dirmngr gnupg apt-transport-https ca-certificates software-properties-common

## Add repository
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/'
RUN apt-get update && apt-get upgrade -y

## Install it
RUN apt-get -y install r-base
RUN apt-get -y install build-essential

##### cube:v02 #####
# - FORCE's prerequisites
RUN apt-get install -y parallel
#RUN parallel --bibtex
RUN apt-get install -y libgdal-dev gdal-bin
# Note: python-gdal is not available for Ubuntu 20
RUN apt-get install -y libgsl0-dev
RUN apt-get install -y curl
RUN apt-get install -y unzip
RUN apt-get install -y lockfile-progs
RUN apt-get install -y rename
RUN apt-get install -y pandoc
RUN apt-get install -y wget
RUN apt-get install -y git
RUN apt-get install -y libpoppler-cpp-dev
RUN apt-get install -y libudunits2-dev
RUN apt-get install -y python3-pip

## Python packages
RUN pip install numpy gsutil shapely pylandsat

## R packages
RUN Rscript -e 'install.packages("rmarkdown")'
RUN Rscript -e 'install.packages("plotly")'
RUN Rscript -e 'install.packages("stringi")'
RUN Rscript -e 'install.packages("knitr")'
RUN Rscript -e 'install.packages("dplyr")'
RUN Rscript -e 'install.packages("devtools")'
RUN Rscript -e 'devtools::install_github("s-u/unixtools", ref = "master")'

##### cube:v03 #####
# - Cmake
RUN mkdir -p ~/src/cmake \ 
    && cd ~/src/cmake \
    && wget https://github.com/Kitware/CMake/releases/download/v3.20.0/cmake-3.20.0.tar.gz \
    && tar -zxvf cmake-3.20.0.tar.gz \
    && cd cmake-3.20.0 \
    && ./bootstrap \
    && make \
    && make install
# Note: there's a newer version available

##### cube:v04 #####
# - Open CV
RUN mkdir -p ~/src/opencv && cd ~/src/opencv \
    && git clone https://github.com/opencv/opencv.git \
    && git clone https://github.com/opencv/opencv_contrib.git \
    && cd opencv \
    && mkdir build \
    && cd build \
    && cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/usr/local .. \
    && make -j7 \
    && make install \
    && make clean

##### cube:v05 #####
# - FORCE
RUN cd ~/src \
    && git clone https://github.com/davidfrantz/force.git \
    && cd force \
    && make -j \
    && make install

##### cube:v06 #####
# - makeDataCube
RUN Rscript -e 'devtools::install_github("RETURN-project/makeDataCube")'
RUN git clone https://github.com/RETURN-project/makeDataCube.git ~/src/makeDataCube
# Consider installing locally

##### Interactivity required #####

# gsutil configuration
# gsutil config Creates the .boto file

# DEM chunk
# Enter NASA Earthdata Login Username 
# (or create an account at urs.earthdata.nasa.gov):******
# Enter NASA Earthdata Login Password:****************
#
# When running interactivelly a popup will appear. Follow instructions or add .netrc file

# WVP chunk
# Requires .laads file

# Check R version
CMD R --version

# Check force
CMD force

# Delaying .. apt-utils is not installed