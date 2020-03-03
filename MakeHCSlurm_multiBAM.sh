

#inputlist=$1
ref=$1      ; shift
output="$1" ; shift
bamout="$1" ; shift
sample="$1" ; shift
inputarray="$@"

slurmfile=haplotypecaller-${sample}.sl

#tmpdir=/scratch2/irri/irri-bioinformatics/dima-scratch2/tmp
tmpdir=tmp

function join_by { local IFS="$1"; shift; echo "$*"; }

input=`join_by " -I " ${inputarray[@]} `

>$slurmfile cat <<EOF
#!/bin/bash

#SBATCH -J hc-$sample
#SBATCH -o  hc-$sample.%j.out
#SBATCH --cpus-per-task=12
#SBATCH --partition=batch
#SBATCH -e hc-$sample.%j.error
#SBATCH --mail-user=d.chebotarov@irri.org
#SBATCH --mail-type=ALL
#SBATCH --requeue
#SBATCH --mem=10G

module load gatk

#inputbam=$input
ref=$ref
output=$output
bamout=$bamout
#bamout=${output%.vcf}.bamout.bam

gatk   HaplotypeCaller \\
    -R \$ref \\
    -I $input \\
    -O \$output \\
    -ERC GVCF \\
     --min-pruning 2 \\
    --max-reads-per-alignment-start 50 \\
    --bam-output \$bamout  \\
  --native-pair-hmm-threads 8 \\
  --java-options "-Xmx9g" \\
  --smith-waterman FASTEST_AVAILABLE \\
  --showHidden true \\

# -G StandardAnnotation -G AS_StandardAnnotation -G StandardHCAnnotation

EOF


