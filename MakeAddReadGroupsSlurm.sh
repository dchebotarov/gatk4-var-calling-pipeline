

input=$1
output=$2
sample="$3"

slurmfile=addrep-${sample}.sl


>$slurmfile cat <<EOF
#!/bin/bash

#SBATCH -J addrep-$sample
#SBATCH -o  addrep-$sample.%j.out
#SBATCH --cpus-per-task=5
#SBATCH --partition=batch
#SBATCH -e addrep-$sample.%j.error
#SBATCH --mail-type=ALL
#SBATCH --requeue
#SBATCH --mem=7G

module load gatk

mkdup_bam=$input
addrep_bam=$output
SID=$sample

# For PU ideally need
# PU = FLOWCELL.LANE.SAMPLEBARCODE


/opt/hpcc/gatk/4.0.5.2/bin/gatk  AddOrReplaceReadGroups \\
  	--INPUT=\$mkdup_bam \\
  	--OUTPUT=\$addrep_bam \\
  	--RGID=\$SID \\
  	--RGPU=\$SID \\
  	--RGLB=\$SID \\
  	-PL=Illumina \\
  	-SM=\$SID \\
  	-CN=CN \\
  	--VALIDATION_STRINGENCY=LENIENT \\
  	-SO=coordinate \\
  	--CREATE_INDEX=TRUE

EOF

