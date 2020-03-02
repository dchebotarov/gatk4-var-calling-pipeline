
usage(){
 echo "Usage:"
 echo " $0 <path-to-reference-fasta-file>"
}

ref=$1

if [[ $# -lt 1 ]] ; then
 usage ; exit -1
fi

bwa index $ref

# Make dict
gatk CreateSequenceDictionary -R $ref

# Make index

samtools faidx $ref


