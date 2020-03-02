
# gatk4-var-calling-pipeline

This is a pipeline for variant calling based on best practices for GATK 4. It was used for processing of rice (O.sativa) NGS data. Note that certain steps, such as BQSR and VQSR) are not included.

The pipeline consists of several scripts that help create SLURM files for variant calling. 
The pipeline itself does not submit the SLURM files. 
Thus, when dealing with large datasets, more automated solutions based on workflow managers are highly recommended. (E.g. a Snakemake variant calling pipeline).


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

#### In version v0.1:

1. First, prepare a "paired list" of fastQ files - a text file with two columns, holding read1 and read2 files for each sample. 
 This can be done with (assuming your FASTQ files are in the directory `data/fastq`)
 ```
 cd data/fastq
 ../../make_fastq_pairlist.sh > pairlist.txt
 ```

(Note: we assume only one pair of fastq files per sample.)

2. Run:

```
./makeScriptsAll.sh  fastq_pair_list  data_dir
```

#### Version v0.4

1. Prepare a `units.txt` file that lists each sample and unit within sample, with corresponding pair of FASTQ files. This should be a tab- or space-separated text file. An example:
```
sample	unit	platform	fq1	fq2
Sample1	1	ILLUMINA	data/fastq/rg-1_1.fq.gz	data/fastq/rg-1_2.fq.gz
IRIS_313-11881	1	ILLUMINA	data/fastq/IRIS_313-11881-rg1_1.fq.gz	data/fastq/IRIS_313-11881-rg1_2.fq.gz
IRIS_313-11881	2	ILLUMINA	data/fastq/IRIS_313-11881-rg2_1.fq.gz	data/fastq/IRIS_313-11881-rg2_2.fq.gz
IRIS_313-11881	3	ILLUMINA	data/fastq/IRIS_313-11881-rg3_1.fq.gz	data/fastq/IRIS_313-11881-rg3_2.fq.gz
IRIS_313-11881	4	ILLUMINA	data/fastq/IRIS_313-11881-rg4_1.fq.gz	data/fastq/IRIS_313-11881-rg4_2.fq.gz
IRIS_313-11881	5	ILLUMINA	data/fastq/IRIS_313-11881-rg5_1.fq.gz	data/fastq/IRIS_313-11881-rg5_2.fq.gz
IRIS_313-11881	6	ILLUMINA	data/fastq/IRIS_313-11881-rg6_1.fq.gz	data/fastq/IRIS_313-11881-rg6_2.fq.gz
```

2. Run
```
./makeAll.sh units.txt <reference file>
```

## Customization
Beforre using, you would probably need to customize the SLURM setting for your cluster, such as CPU cores per task, memory, email address etc.

These are found in the files starting with "Make...": MakeAlignSlurm.sh etc in the rows starting `#SBATCH`. Please refer to SLURM documentation for meaning of each setting.

Update these settings for each kind of job (each `Make<...>.sh` file

