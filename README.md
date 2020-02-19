# gatk4-var-calling-pipeline
A pipeline for variant calling based on best practices for GATK 4.0

The purpose of these commands is to easily create SLURM files for variant calling.

## Usage
### Creating SLURM files for a particular sample
To create SLURM files for a single sample, use the following command
```
 ./perSampleScripts  sample read1 read2 outdir ref
```

Example:
```
./perSampleScripts.sh XH109  \
   /data/Project1/XH109_HCTVGALXX_L2/XH109_HCTVGALXX_L2_1.clean.fq.gz \
   /data/Project1/XH109_HCTVGALXX_L2/XH109_HCTVGALXX_L2_1.clean.fq.gz  \
    output/XH109  \
    ref/IR8.fa 
```

This will create the following SLURM scripts (to be run in this order)

```
aln-${sample}.sl 
fixmate-${sample}.sl 
markdup-${sample}.sl 
addrep-${sample}.sl 
haplotypecaller-${sample}.sl 
```
where ${sample} will be replaced by the given sample name.

Before running these scripts, you may need to prepare the reference data by using

```
./prepare_reference.sh <path-to-reference>
```


### Creaing SLURM files for all samples in the dataset
1. First, prepare a "paired list" of fastQ files - a text file with two columns, holding read1 and read2 files for each sample.

(Note: here we assume there is only one pair of fastq files per sample.)

2. Run:

```
./makeScriptsAll.sh  fastq_pair_list  data_dir
```

## Customization
Beforre using, you would probably need to customize the SLURM setting for your cluster, such as cpu cores per task, memory, email address etc.

These are found in the files starting with "Make...": MakeAlignSlurm.sh etc in the rows starting `#SBATCH`. Please refer to SLURM documentation for meaning of each setting.

Update these settings for each kind of job (each `Make<...>.sh` file

