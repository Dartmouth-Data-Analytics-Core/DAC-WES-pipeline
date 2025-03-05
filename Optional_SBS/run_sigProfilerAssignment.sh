#! /usr/bin/bash

#!/bin/bash
#SBATCH --job-name=GATK
#SBATCH --nodes=1
#SBATCH --partition=standard
#SBATCH --time=60:00:00
#SBATCH --mail-user=f007qps@dartmouth.edu
#SBATCH --mail-type=FAIL
#SBATCH --output=GATK_%j.out

#----- START
echo "Starting job: $SLURM_JOB_NAME (Job ID: $SLURM_JOB_ID)"
echo "Running on node: $(hostname)"
echo "Start time: $(date)"
echo -e "#-----------------------------------------------------------#\n"

#----- SOURCE AND ACTIVATE CONDA
source /dartfs-hpc/rc/lab/G/GMBSR_bioinfo/misc/owen/sharedconda/miniconda/etc/profile.d/conda.sh
conda activate  /dartfs-hpc/rc/lab/G/GMBSR_bioinfo/misc/owen/sharedconda/miniconda/envs/SigProfilerAssignment

#----- Set MAF folder location
MAF_FOLDER="<PATH/TO/MAFs>"
GENOME_BUILD="<genome_build>"
SAMPLE="<SINGLE_SAMPLE_ID>" # Just put the sample ID of ONE sample, this is to generate a temp file downstream. 

#----- Move into SigProfilerAssignment Folder
cd SigProfilerAssignment

#----- Install the reference genome you need
python install_reference_genome.py --reference mm10

#----- Trim the MAF files
python trim_maf.py \
    --mode folder --input "$MAF_FOLDER" \
    --output-folder trimmed-mafs \
    --output-suffix "maf"

#----- Create a list of each maf file
ls trimmed-mafs | cut -d "/" -f2|cut -d "." -f1 > mafs.list

#----- Create a directory for each maf file
for i in `cat mafs.list`; do 
    mkdir $i;
done

# copy the trimmed maf files into their own directories
for i in `cat mafs.list`; do 
    cp trimmed-mafs/"$i".maf "$i"/;
done

# run sig profiler in a loop  across each maf file
for i in `cat mafs.list`; do 
    python sig_profiler_assignment.py \
    -i "$i" \
    -o "$i"-outputs \
    --write-results-per-sample \
    --genome-build "$GENOME_BUILD";
done


#----- Add the columns for each SBS type
head -n1 "$SAMPLE"/SBS_contributions.txt > temp_SBS_contributions.txt

#----- add a line for SBS proportions in each sample
for i in `cat mafs.list`; do 
    tail -n1 "$i"/SBS_contributions.txt >> temp_SBS_contributions.txt;
done

#----- Create a column with sample names to label rows in the table
printf "sample\n$(cat mafs.list)"> rownames.list

#----- Add rownames to the file with SBS contributions for each file 
paste rownames.list temp_SBS_contributions.txt > all_SBS_contributions.txt

echo "End time: $(date)"