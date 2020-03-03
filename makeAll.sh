#!/bin/bash 

set -euo pipefail

usage(){
	echo "Usage: $0 units_file reference"
	exit -1
}

if [[ "$#" -lt 2 ]] ; then 
	usage
fi

units_file=$1

ref=$2



# For each row in PairedList

while read -r sample unit platform rd1 rd2 remainder 
do 
	sampleunit=${sample}_$unit

	echo "Sample: $sample"
	echo rd1=$rd1 rd2=$rd2
	
	# Extract Sample ID - dataset specific. Edit the file extensions to remove
	prefix=${in1%1.fq*} # edit 

	# Create a subdirectory equal to sample name
	sample_script_dir=$sample
	unit_script_dir=$sample/$unit
	commanddir=$sample
	
	mkdir -p $sample_script_dir
	mkdir -p $unit_script_dir

	outdir=output/$sample
	mkdir -p output/$sample
	mkdir -p output/$sample/$unit


	# Create per sample SLURM files
    ./perSampleReadGroupScripts.sh "$sample" "$unit"  "$rd1"  "$rd2" "output/$sample/$unit" "$ref"

	# Create "aggregated" SLURM files, for easier submission (at the price of same configuration for all job steps, which is suboptimal)
	echo "cat aln-${sampleunit}.sl fixmate-${sampleunit}.sl markdup-${sampleunit}.sl addrep-${sampleunit}.sl   > fq2bam-${sampleunit}.sl " | sh

	#echo "cat  fixmate-${sample}.sl markdup-${sample}.sl addrep-${sample}.sl haplotypecaller-${sample}.sl  cleanup-${sample}.sl  > after-aln-${sample}.sl " | sh
	# Move all scripts into the directory for the sample
	echo "mv *-${sampleunit}.sl  $unit_script_dir"  | sh

done < <(tail -n+2 $units_file)

### For each sample:
# 1. merge BAM files of each read group
# or symlink the BAM file , if only one
 # 2. HC

samplefile="sampleunits.count"
sampleunit1="sampleunits.1"
tail -n+2 $units_file | sort | uniq | awk '{print $1}' | uniq -c > $samplefile

tail -n+2 $units_file | sort | uniq | awk '{ if($1 in sm){sm[$1] = sm[$1] " " $2;} else {sm[$1]=$2} } END {for(s in sm){print s,sm[s]}}' > $sampleunit1

unfinished="unfinished.log.txt"
echo "Sample nUnits nBam" > $unfinished

function join_by { local IFS="$1"; shift; echo "$*"; }

#for sample in `cat $samplefile` ; do
while read -r nlib sample ; do
	echo "Sample: $sample"
	echo ". pairs of FASTQ files: $nlib"

	# check if multiple BAMs
	outdir=output/$sample
	bams=( $(find $outdir -name "*addrep.bam") )
	num_bams=${#bams[@]}
	echo ". final BAM files: $num_bams"

	if [[ $num_bams -ne $nlib ]] ; then
		echo $sample $nlib $num_bams >> $unfinished
	fi
	if [[ $num_bams -gt 0 ]] ; then
		finalBAMlist=`join_by '|' "${bams[@]}" | sed 's:|: -I :g' ` 
	else
		echo ". Skipping creating SLURM files since no BAM files were found for $sample"
		continue
	fi
	# HaploTypeCaller
	gvcf=${outdir}/${sample}.g.vcf  # Output gVCF 
	bamout=${outdir}/${sample}.bamout.bam  # BAM file for target regions that is output by HaplotypeCaller

	mergedBAM=${outdir}/${sample}.bam
	if [[ $num_bams -gt 1 ]] ; then
		# Merge multiple bam files - optional 
		./MakeMergeBamSlurm.sh $ref $mergedBAM $sample ${bams[@]}
	else 
		# provide a final addrep BAM
		echo "Symlinking a single library BAM as final BAM for $sample"
		ln -s $finalBAMlist $mergedBAM
	fi
	#./MakeHCSlurm.sh  "$finalBAM" $ref  $gvcf $bamout $sample
	./MakeHCSlurm_multiBAM.sh  $ref  $gvcf $bamout $sample $finalBAMlist

	sample_script_dir=$sample
	mv *-${sample}.sl $sample_script_dir
	
done < $samplefile


