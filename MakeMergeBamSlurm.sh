

#inputlist=$1
ref=$1      ; shift
output="$1" ; shift
sample="$1" ; shift
inputarray="$@"

slurmfile=mergeBam-${sample}.sl

tmpdir=tmp

input=${inputarray[@]}

>$slurmfile cat <<EOF
#!/bin/bash

#SBATCH -J mergebam-$sample
#SBATCH -o  mergebam-$sample.%j.out
#SBATCH --cpus-per-task=12
#SBATCH --partition=batch
#SBATCH -e mergebam-$sample.%j.error
#SBATCH --mail-user=USER_EMAIL
#SBATCH --mail-type=ALL
#SBATCH --requeue
#SBATCH --mem=10G

module load samtools

ref=$ref
output=$output

samtools merge -r --reference=\$ref \
  -Obam \$output \
    $input

samtools index \$output

EOF


