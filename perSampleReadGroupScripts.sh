
usage="""
  Usage:  
 perSampleReadGroupScripts  sample rg  read1 read2 outdir ref
"""

if [ "$#" -lt 6  ] ; then
 echo $usage
 exit 
fi

sample=$1 ; shift

rg=$1 ; shift

read1=$1 ; shift

read2=$1 ; shift

outdir=$1 ; shift

ref=$1 ; shift

#script_dir="$1" ; shift


mkdir -p $outdir

#mkdir -p $script_dir

echo "Creating scripts for:"
echo "sample: " $sample
echo "RG: " $rg
echo " FASTQ paired-end read files: " $read1 $read2
echo "Output directory: " $outdir
echo "Reference genome: " $ref
echo

sampleunit=${sample}_${rg}
#### Output files naming ####

sam=${outdir}/${sampleunit}.sam  # SAM file produced by BWA
echo "First SAM file: $sam"

sortedbam=${outdir}/${sampleunit}.sorted.bam # Sorted BAM

fxmt=${outdir}/${sampleunit}.fxmt.bam # BAM after fixing mate info
echo "FixMate output: $fxmt"

mkdup=${outdir}/${sampleunit}.mkdup.bam # BAM after making duplicates
metrics=${outdir}/${sampleunit}.mkdup.metrics # Metrics file for MarkDuplicates

addrep=${outdir}/${sampleunit}.addrep.bam # BAM with fixed read groups
echo "Final BAM file: " $addrep
# gvcf=${outdir}/${sampleunit}.g.vcf  # Output gVCF 

# bamout=${outdir}/${sampleunit}.bamout.bam  # BAM file for target regions that is output by HaplotypeCaller

# Alignment

 ./MakeAlignSlurm.sh $read1 $read2 $ref $sam $sampleunit

# Sort SAM file -> sorted bam

 ./MakeSortSamSlurm.sh $sam $sortedbam $sampleunit

# Fix mate information

# ./MakeFixMatesSlurm.sh $sortedbam $fxmt $sample  # or
./MakeFixMatesSlurm.sh $sam $fxmt $sampleunit # since fixmate sorts by queryorder in the beginning anyway

# Mark duplicates

./MakeMarkdupSlurm.sh $fxmt $mkdup $metrics $sampleunit

# Add or replace read groups

./MakeAddReadGroupsSlurm.sh "$mkdup" "$addrep" "$sample" "$rg" "mult"

# Haplotype caller - not needed

# ./MakeHCSlurm.sh  $addrep $ref  $gvcf $bamout $sample

# CLean up

echo "rm $sam ; rm $fxmt " > cleanup-${sampleunit}.sl 

echo "Done"

