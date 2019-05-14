

input=$1
output=$2
ref="$3"

# ref=/share/home/dima.chebotarov/ref/R498_Chr.fa 


slurmfile=setnm-${sample}.sl


>$slurmfile cat <<EOF
#!/bin/bash

#SBATCH -J setnm-$sample
#SBATCH -o  setnm-$sample.%j.out
#SBATCH --cpus-per-task=5
#SBATCH --partition=batch
#SBATCH -e setnm-$sample.%j.error
#SBATCH --mail-user=d.chebotarov@irri.org
#SBATCH --mail-type=ALL
#SBATCH --requeue
#SBATCH --mem=8G

module load gatk

input=$input
SID=$sample

# For PU ideally need
# PU = FLOWCELL.LANE.SAMPLEBARCODE


/opt/hpcc/gatk/4.0.5.2/bin/gatk  \\
  SetNmAndUqTags \\
      --INPUT  $input \\
      --OUTPUT $output  \\
      --CREATE_INDEX true \\
      --CREATE_MD5_FILE true \\
      --REFERENCE_SEQUENCE ${ref}
  	--VALIDATION_STRINGENCY=LENIENT \\
  	-SO=coordinate \\


EOF

