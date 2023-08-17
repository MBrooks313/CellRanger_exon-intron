# Import modules
import glob
import os
import json
import pandas as pd


##########
# Import config and needed global variables
configfile: "config.json"

bam_dir = config["bam_dir"]
out_dir = config["out_dir"]
bar_suffix = config["barcode_suffix"]


##########
# Get sample IDs
SAMPLES = pd.read_csv(config["sample_file"], header = None)[0].tolist()


##########
# Set suffix values for sam splitting
n = list(range(0, config["split_num"]+1))
SUFFIX = []
for i in n:
    SUFFIX.append(f"x{i:02}")


#############################################################
# List of directories needed and end point files for analysis
#############################################################

BAM = expand(out_dir + "/sam/{sample}_intronexon.sam",  sample=SAMPLES)
SPL = expand(out_dir + "/samSplit/{sample}_{suffix}", sample=SAMPLES, suffix=SUFFIX)
SUM = expand(out_dir + "/csv2sum/{sample}_{suffix}.txt", sample=SAMPLES, suffix=SUFFIX)



##############################
# Snakemake rules for analysis
##############################

localrules: all

rule all:
        input:  SUM
        params:
                batch = config["job_all"]


rule bamFilt:
    """
    # This rule filters the CellRanger bam file for cells indicated by barcodes of interest
    # for only their exon and intron aligned reads.
    # This requires a text file of cell barcodes for the cells of interest for each bam file. 
    # The output is a SAM format file with no header (text file).
    """
    input:
            bam = bam_dir + "/{sample}/outs/possorted_genome_bam.bam",
            bar = "barcodes/{sample}" + bar_suffix
    output:
            out_dir + "/sam/{sample}_intronexon.sam"
    log:    "logs/bamFilt.{sample}.log"
    version:
            config["samtools"]
    params:
            rulename = "bamFilt",
            batch = config["job_bam"],
            out_dir = config["out_dir"]

    shell: """
    module load samtools/{version} || exit 1
    mkdir -p {params.out_dir}/sam
    samtools view -@ ${{SLURM_CPUS_ON_NODE}} -D CB:{input.bar} {input.bam} | \
    grep "RE:A:[EN]" > {output}
    """


rule samSplit:
    """
    # This rule splits each SAM file into 50 chunks.
    """
    input:
            out_dir + "/sam/{sample}_intronexon.sam"
    output:
            files = out_dir + "/samSplit/{sample}_{suffix}"
    log:    "logs/samSplit.{sample}{suffix}.log"
    params:
            rulename = "samSplit",
            batch = config["job_sam"],
            out_dir = config["out_dir"],
            num = config["split_num"]

    shell: """
    mkdir -p {params.out_dir}/samSplit
    split -d -n {params.num} {input} {params.out_dir}/samSplit/{wildcards.sample}_x
    """


rule csv2sum:
    """
    # This rule pulls out the barcode and exon fields from SAM files and summarizes the exon and intron read count numbers per barcode.
    """
    input:
            out_dir + "/samSplit/{sample}_{suffix}"
    output:
            csv_file = out_dir + "/csv2sum/{sample}_{suffix}.csv",
            cat_file = out_dir + "/csv2sum/{sample}_{suffix}.txt"
    log:    "logs/csv2sum.{sample}{suffix}.log"
    version:
            config["R_ver"]
    params:
            rulename = "csv2sum",
            batch = config["job_R"],
            out_dir = config["out_dir"],
            script = config["script_R"]

    shell: """
    mkdir -p {params.out_dir}/csv2sum
    module load R/{version} || exit 1
    Rscript scripts/{params.script} --input {input} --output {output.csv_file}
    cat {output.csv_file} | sort | uniq -c > {output.cat_file}
    """



