
input=$1
output=$2
metrics_file=$3
sample="$4"

slurmfile=markdup-${sample}.sl

#tmpdir=/scratch2/irri/irri-bioinformatics/dima-scratch2/tmp
tmpdir=tmp

>$slurmfile cat <<EOF
#!/bin/bash

#SBATCH -J mkdp-$sample
#SBATCH -o  mkdp-$sample.%j.out
#SBATCH --cpus-per-task=5
#SBATCH --partition=batch
#SBATCH -e mkdp-$sample.%j.error
#SBATCH --mail-type=ALL
#SBATCH --requeue
#SBATCH --mem=9G

module load gatk

fxmt_bam=$input
mkdup_bam=$output
metrics_file=$metrics_file

gatk   MarkDuplicates \\
 	--INPUT=\$fxmt_bam \\
 	--OUTPUT=\$mkdup_bam \\
 	--VALIDATION_STRINGENCY=LENIENT \\
 	--CREATE_INDEX=TRUE \\
 	--METRICS_FILE=\$metrics_file \\
	--java-options "-Xmx8g" \\
         --TMP_DIR=$tmpdir  \\
 	--MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 

EOF


