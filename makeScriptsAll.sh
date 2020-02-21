#!/bin/bash
##########
# Create SLURM scripts for all samples in the dataset

# Usage:  $0  fastq_pair_list data_dir ref
# where fastq_pair_list is a file with one row per sample listing read1 fastq file in column 1 and read2 in column 2.
# and data_dir is the directory to search for these files.
# ref is the path to reference sequence

# Assumptions: 
#  exactly two FASTQ files per sample. If there are multiple libraries/runs per sample, an additional merging step before HaplotypeCaller will be needed.
#  the FASTQ file names end in _1.clean.fq.gz, _2.clean.fq.gz . (If not, please edit the Extract Sample ID section below.

###########

# Input: a text file with two columns that list read1 file and  read2 file names (not paths) for each sample in the dataset
pairedlist=$1

# Input: a directory where to search for FASTQ files
# DATADIR=/scratch2/irri/irri-bioinformatics/dima-scratch2/DXH114   #  /home/dima.chebotarov/Data
DATADIR=$2

ref=$3

# For each row in PairedList

while read -r in1 in2 remainder 
do 
	# Find actual files (@deprecate; use table sample unit read1path read2path)
	rd1=`find $DATADIR -name $in1`
	rd2=`find $DATADIR -name $in2`

	if [ -z "$rd1"  ] ; then
		echo Could not find fastq file $in1 in $DATADIR  
		continue
	fi 
	echo rd1=$rd1 rd2=$rd2
	
	# Extract Sample ID - dataset specific. Edit the file extensions to remove
	prefix=${in1%1.fq*} # edit 
	SID=${prefix##*/}
	sample=${SID%_*}
	echo "# SAMPLE: $sample "

	# Create a subdirectory equal to sample name
	commanddir=$sample
	mkdir -p $commanddir
	mkdir -p output/$sample

	# Create per sample SLURM files
    ./perSampleScripts.sh "$sample"  "$rd1"  "$rd2" "output/$sample" "$ref"

	# Create "aggregated" SLURM files, for easier submission (at the price of same configuration for all job steps, which is suboptimal)
	echo "cat aln-${sample}.sl fixmate-${sample}.sl markdup-${sample}.sl addrep-${sample}.sl haplotypecaller-${sample}.sl  > all-${sample}.sl " | sh
	echo "cat aln-${sample}.sl fixmate-${sample}.sl markdup-${sample}.sl addrep-${sample}.sl   > fq2bam-${sample}.sl " | sh
	echo "cat  fixmate-${sample}.sl markdup-${sample}.sl addrep-${sample}.sl haplotypecaller-${sample}.sl  cleanup-${sample}.sl  > after-aln-${sample}.sl " | sh
	# Move all scripts into the directory for the sample
	echo "mv *-${sample}.sl  $commanddir"  | sh

done < "$pairedlist"

