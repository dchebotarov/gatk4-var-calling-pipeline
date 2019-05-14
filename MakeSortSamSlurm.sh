

sam=$1
output=$2
# output=${sam%.sam}.sorted.bam

sample="$3"

slurmfile=sortsam-${sample}.sl

tmpdir=/scratch2/irri/irri-bioinformatics/dima-scratch2/tmp


>$slurmfile cat <<EOF
#!/bin/bash

#SBATCH -J srt-$sample
#SBATCH -o srt-$sample.%j.out
#SBATCH --cpus-per-task=8
#SBATCH --partition=batch
#SBATCH -e srt-$sample.%j.error
#SBATCH --mail-user=d.chebotarov@irri.org
#SBATCH --mail-type=ALL
#SBATCH --requeue
#SBATCH --mem=16G

#module load gatk/3.6

module load gatk

sam=$1
output=$output

/opt/hpcc/gatk/4.0.5.2/bin/gatk SortSam \\
  	--INPUT=\$sam \\
  	--OUTPUT=\$output \\
  	--SORT_ORDER=coordinate \\
  --java-options "-Xmx15g" \\
  --TMP_DIR=$tmpdir \\


#  	VALIDATION_STRINGENCY=LENIENT \\
#  	CREATE_INDEX=TRUE 

EOF


