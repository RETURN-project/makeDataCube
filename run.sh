#!/bin/bash
#SBATCH -N 1      #request 1 node
#SBATCH -c 1      #request 1 core and 8000 MB RAM
#SBATCH -t 59:00  #request 59 minutes jobs slot
#SBATCH -p short  #request short partition

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

# Other parameters
SIFIMAGE="/project/return/Software/containers/k.sif"
VIGNETTE="vignettes/make_Landsat_cube.Rmd"

# Execute
singularity exec "$SIFIMAGE" \
    Rscript -e "rmarkdown::render('${VIGNETTE}', params = list(starttime = '${STARTTIME}', endtime = '${ENDTIME}'))"

# Wanda runs this at home/wanda
# Inside a batch
# singularity exec --bind /project/return/ --pwd $PWD /project/return/Software/containers/k.sif Rscript -e "rmarkdown::render('path-to-rmd.Rmd')"
