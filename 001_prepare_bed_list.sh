#! /usr/bin/bash

#!/bin/bash
#SBATCH --job-name=GATK
#SBATCH --nodes=1
#SBATCH --partition=standard
#SBATCH --time=60:00:00
#SBATCH --mail-user=XXXXqps@dartmouth.edu
#SBATCH --mail-type=FAIL
#SBATCH --output=GATK_%j.out

#----- START
echo "Starting job: $SLURM_JOB_NAME (Job ID: $SLURM_JOB_ID)"
echo "Running on node: $(hostname)"
echo "Start time: $(date)"
echo -e "#-----------------------------------------------------------#\n"

#----- Set paths
TARGETS="Twist_Mouse_Exome_Target_Rev1_7APR20.bed"
REF="/dartfs-hpc/rc/lab/G/GMBSR_bioinfo/genomic_references/mouse/UCSC_mm10/mm10.fa"
ORG="mm10"

#----- Source conda
source /optnfs/common/miniconda3/etc/profile.d/conda.sh
conda activate /dartfs-hpc/rc/lab/G/GMBSR_bioinfo/misc/owen/sharedconda/miniconda/envs/gatk4

#----- Create sequence dictionary
gatk CreateSequenceDictionary -R "$REF" -O "$ORG".dict

#----- Convert to interval list format
gatk BedToIntervalList \
    -I "$TARGETS" \
    -O "$ORG".interval_list \
    -SD "$ORG".dict

#----- Split bed file into regions, add regions to list
split -l 2155 "$TARGETS"
ls x* > bed.list

