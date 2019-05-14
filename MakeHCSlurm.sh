

input=$1
ref=$2
output=$3
bamout=$4
sample="$5"

slurmfile=haplotypecaller-${sample}.sl

tmpdir=/scratch2/irri/irri-bioinformatics/dima-scratch2/tmp

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

inputbam=$input
ref=$ref
output=$output
bamout=$bamout
#bamout=${output%.vcf}.bamout.bam

/opt/hpcc/gatk/4.0.5.2/bin/gatk   HaplotypeCaller \\
    -R \$ref \
    -I \$inputbam \
    -O \$output \\
    -ERC GVCF \\
     --min-pruning 2 \\
    --max-reads-per-alignment-start 50 \\
    --bam-output \$bamout  \\
  --native-pair-hmm-threads 8 \\
  --java-options "-Xmx9g" \\
  --TMP_DIR=$tmpdir  \\
  --smith-waterman FASTEST_AVAILABLE \\
  --showHidden true \\

# -G StandardAnnotation -G AS_StandardAnnotation -G StandardHCAnnotation

EOF


