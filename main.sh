#!/bin/bash
#SBATCH -N 1      #request 1 node
#SBATCH -c 1      #request 1 core and 8000 MB RAM
#SBATCH -t 59:00  #request 59 minutes jobs slot
#SBATCH -p short  #request short partition

# Usage:
# SLURM_ARRAY_TASK_ID=2 ./main.sh inputs.csv 
# or
# sbatch --array=2-3 -N1 ./main.sh inputs.csv 

# Parse variables from line in csv file
line=`sed "${SLURM_ARRAY_TASK_ID}q;d" $1`
IFS=, read STARTTIME ENDTIME <<< "$line"

# Check parsed information
echo "$line"
echo "$STARTTIME"
echo "$ENDTIME"

# Build and run the desired command
./run.sh -s "$STARTTIME" -e "$ENDTIME"