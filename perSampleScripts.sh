
usage="""
  Usage:  
 perSampleScripts  sample read1 read2 outdir ref
"""

if [ "$#" -lt 5  ] ; then
 echo $usage
 exit 
fi

sample=$1

read1=$2

read2=$3

outdir=$4

ref=$5

mkdir -p $outdir

#### Output files naming ####

sam=${outdir}/${sample}.sam  # SAM file produced by BWA

sortedbam=${outdir}/${sample}.sorted.bam # Sorted BAM

fxmt=${outdir}/${sample}.fxmt.bam # BAM after fixing mate info

mkdup=${outdir}/${sample}.mkdup.bam # BAM after making duplicates
metrics=${outdir}/${sample}.mkdup.metrics # Metrics file for MarkDuplicates

addrep=${outdir}/${sample}.addrep.bam # BAM with fixed read groups

gvcf=${outdir}/${sample}.g.vcf  # Output gVCF 

bamout=${outdir}/${sample}.bamout.bam  # BAM file for target regions that is output by HaplotypeCaller

# Alignment

 ./MakeAlignSlurm.sh $read1 $read2 $ref $sam $sample

# Sort SAM file -> sorted bam

 ./MakeSortSamSlurm.sh $sam $sortedbam $sample

# Fix mate information

# ./MakeFixMatesSlurm.sh $sortedbam $fxmt $sample  # or
./MakeFixMatesSlurm.sh $sam $fxmt $sample # since fixmate sorts by queryorder in the beginning anyway

# Mark duplicates

./MakeMarkdupSlurm.sh $fxmt $mkdup $metrics $sample

# Add or replace read groups

./MakeAddReadGroupsSlurm.sh $mkdup $addrep $sample

# Haplotype caller

./MakeHCSlurm.sh  $addrep $ref  $gvcf $bamout $sample

# CLean up

echo "rm $sam ; rm $fxmt " > cleanup-${sample}.sl 


