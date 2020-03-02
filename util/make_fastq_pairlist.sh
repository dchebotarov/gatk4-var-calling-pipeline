
# Run this script from the directory where your FASTQ are located

paste <( find . -name "*1.fq*" | sort )  <( find  . -name "*2.fq*" | sort ) | sed 's|[.]/||g' 


