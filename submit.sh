#!/bin/sh

# Run with: sbatch --time=24:00:00 submit.sh

#####################################
# This script is the CellRanger Exon Intron Counts submit script for a snakemake pipeline.
# This pipeline was created by Matthew J Brooks in August 2023
# This pipeline adapted to run on HPCs running SLURM
# This requires the snakefile exint_snakemake.py, config.json, samples.txt, and a list of cell barcodes per sample
#####################################

# Load module
module load python/3.10

# Export variables
NOW=$(date +"%Y%m%d")
export WORK_DIR="<path/to/working/directory>/src"
SNAKEFILE=exint_snakefile.py

# Make result directories and change into result directory
mkdir -p ${WORK_DIR}/logs
cd $WORK_DIR

# Snakemake command
echo "Get ready for snakemake..." >> logs/snakemake.%j.o
snakemake\
	--directory $WORK_DIR \
	--snakefile $SNAKEFILE \
	--jobname '{rulename}.{jobid}' \
	--rerun-incomplete \
	--nolock \
	--verbose \
	-k -p \
	-j 3000 \
	--stats pipeline_${NOW}.stats \
	--cluster "sbatch --mail-type=FAIL -o logs/{params.rulename}.%j.o {params.batch}" \
	>& pipeline_${NOW}.log

# Summary
#  snakemake --directory $WORK_DIR --snakefile $SNAKEFILE --configfile $SAM_CONFIG --summary

## DRY Run with Print out the shell commands that will be executed
#  snakemake --directory $WORK_DIR --snakefile $SNAKEFILE --configfile $SAM_CONFIG --dryrun -p -r
# snakemake --directory $WORK_DIR --snakefile $SNAKEFILE --dryrun -p -r

#DAG
 # snakemake --directory $WORK_DIR --snakefile $SNAKEFILE  --dag | dot -Tpng > dag.png

#Rulegraph
#  snakemake --directory $WORK_DIR --snakefile $SNAKEFILE  -n --forceall --rulegraph | dot -Tpng > rulegraph.png

# Mail Rulegraph and DAG to self
#  echo DAG |mutt -s "DAG" -a dag.png -a rulegraph.png -- brooksma@mail.nih.gov
