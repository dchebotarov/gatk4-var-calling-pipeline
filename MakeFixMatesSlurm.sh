

bam=$1
output=$2
sample="$3"

slurmfile=fixmate-${sample}.sl

#tmpdir=/scratch2/irri/irri-bioinformatics/dima-scratch2/tmp
tmpdir=tmp

>$slurmfile cat <<EOF
#!/bin/bash

#SBATCH -J fxmt-$sample
#SBATCH -o fxmt-$sample.%j.out
#SBATCH --cpus-per-task=5
#SBATCH --partition=batch
#SBATCH -e fxmt-$sample.%j.error
#SBATCH --mail-type=ALL
#SBATCH --requeue
#SBATCH --mem=9G

module load gatk


# Input a .sorted.bam file from SortSam step
baminput=$1

# Output file
#fixmate_bam_output=${baminput%.sorted.bam}.fxmt.bam
output=$output

# Provide the correct path for GATK
# java -Xmx8g -jar $picardjar  FixMateInformation \

gatk \\
  FixMateInformation \\
  --INPUT=\$baminput \\
  --OUTPUT=\$output \\
  --CREATE_INDEX=TRUE \\
  --VALIDATION_STRINGENCY=LENIENT \\
  --java-options "-Xmx8g" \\
  --TMP_DIR=$tmpdir \\
  -SO=coordinate \\

#  VALIDATION_STRINGENCY=LENIENT \\

EOF

