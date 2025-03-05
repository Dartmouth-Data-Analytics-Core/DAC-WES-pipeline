#!/bin/bash
#SBATCH --job-name=WES_Pipeline
#SBATCH --nodes=1
#SBATCH --partition=preempt1
#SBATCH --account=dac
#SBATCH --time=60:00:00
#SBATCH --mail-user=XXXXqps@dartmouth.edu
#SBATCH --mail-type=FAIL
#SBATCH --output=WES_Pipeline_%j.out

#----- START
echo "Starting job: $SLURM_JOB_NAME (Job ID: $SLURM_JOB_ID)"
echo "Running on node: $(hostname)"
echo "Start time: $(date)"
echo -e "#-----------------------------------------------------------#\n"

#----- SOURCE CONDA ENVIRONMENT
source /dartfs-hpc/rc/lab/G/GMBSR_bioinfo/misc/owen/sharedconda/miniconda/etc/profile.d/conda.sh
conda activate /dartfs/rc/nosnapshots/G/GMBSR_refs/envs/snakemake

#----- RUN SNAKEMAKE WORKFLOW
snakemake -s Snakefile \
    --use-conda \
    --conda-frontend conda \
    --conda-prefix /dartfs/rc/nosnapshots/G/GMBSR_refs/envs/DAC-RNAseq-pipeline \
  	--rerun-incomplete \
    --keep-going \
    --profile cluster_profile 

#----- GENERATE RULE GRAPH OR DRY RUN
#snakemake --rulegraph | dot -Tpng > rulegraph.png
#snakemake -np

#----- END
echo "Ending job: $SLURM_JOB_NAME (Job ID: $SLURM_JOB_ID)"
echo "Running on node: $(hostname)"
echo "End time: $(date)"
echo -e "#-----------------------------------------------------------#\n"