
read1=$1
read2=$2
ref=$3
out_sam=$4
samplename="$5"

slurmfile=aln-${samplename}.sl

>$slurmfile  cat  <<EOF
#!/bin/bash

#SBATCH -J aln-$samplename
#SBATCH -o aln-$samplename.%j.out
#SBATCH --cpus-per-task=9
#SBATCH --partition=batch
#SBATCH -e aln-$samplename.%j.error
#SBATCH --mail-type=ALL
#SBATCH --requeue
#SBATCH --mem=10G

module load bwa 

read1=$read1
read2=$read2
out_sam=$out_sam
ref_file=$ref

echo Started \`date\`

bwa mem -M -t 8   \$ref_file \$read1 \$read2  > \$out_sam  

echo Finished \`date\`

EOF


