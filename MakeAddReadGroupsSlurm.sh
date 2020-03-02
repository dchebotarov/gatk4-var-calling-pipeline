

input=$1 ; shift
output=$1 ; shift
sample="$1" ; shift
unit="$1" ; shift
#lb="$1" ; shift

sampleOut=$sample
if [[ "$1" == "mult" ]] ; then
  sampleOut=${sample}_${unit} # no, sample should be still the same
fi

slurmfile=addrep-${sampleOut}.sl
>$slurmfile cat <<EOF
#!/bin/bash

#SBATCH -J addrep-$sampleOut
#SBATCH -o  addrep-$sampleOut.%j.out
#SBATCH --cpus-per-task=5
#SBATCH --partition=batch
#SBATCH -e addrep-$sampleOut.%j.error
#SBATCH --mail-type=ALL
#SBATCH --requeue
#SBATCH --mem=7G

module load gatk

mkdup_bam=$input
addrep_bam=$output

SID=$sample
unit=$unit
lb=$lb

# For PU ideally need
# PU = FLOWCELL.LANE.SAMPLEBARCODE


gatk  AddOrReplaceReadGroups \\
  	--INPUT=\$mkdup_bam \\
  	--OUTPUT=\$addrep_bam \\
  	--RGID="\$SID\$lb\$unit" \\
  	--RGPU="\$SID\$unit" \\
  	--RGLB="\$SID\$lb" \\
  	-PL=Illumina \\
  	-SM=\$SID \\
  	-CN=CN \\
  	--VALIDATION_STRINGENCY=LENIENT \\
  	-SO=coordinate \\
  	--CREATE_INDEX=TRUE

EOF

