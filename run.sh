#!/bin/bash

# Example of usage:
#
# ./run.sh -s "2000-11-1" -e "2001-5-28"

# Parse parameters
while getopts s:e: flag
do
    case "${flag}" in
        s) STARTTIME=${OPTARG};;
        e) ENDTIME=${OPTARG};;
    esac
done

# Execute
singularity exec /project/return/Software/containers/k.sif \
    Rscript -e "rmarkdown::render('vignettes/make_Landsat_cube.Rmd', params = list(starttime = '${STARTTIME}', endtime = '${ENDTIME}'))"

# Wanda runs this at home/wanda
# Inside a batch
# singularity exec --bind /project/return/ --pwd $PWD /project/return/Software/containers/k.sif Rscript -e "rmarkdown::render('path-to-rmd.Rmd')"
