# CellRanger_exon-intron_counts
This snakemake subsets a CellRanger output BAM file for cells of interest then summarizes the exon and intron aligned read counts per cell barcode.

## General workflow
	+ Parse the bam file for exon and intron reads for barcodes of interest.
		+ Output is a SAM format file with no header...so a text file
	+ Split the SAM file into 50 smaller SAM files
	+ Pull out the CB:xxxxxx and exon/intron columns (RE:A:xxxxxx) from the SAM file and summarize per barcode
		+ The R script used to pull out the CB:xxxxxx and exon/intron info is pretty slow, ~1M reads per hour, so splitting and parallelizing is the only way to make the processing manageable time-wise.
	+ Summarize the exon/intron counts per barcode per sample


## Required inputs:
	+ Text file of cell barcodes to retrieve from the sample bam file. 
		+ These barcodes can be found in the colnames of a Seurat object for example. 
		+ They must match the format of the CB:xxxxx tag field in the bam file.
		+ The barcodes are specific for each bam file and therefore a barcode file is required for each bam file to be filtered. 
	+  Text file of the sample names in the CellRanger output
		+ The sample directory name in the Cell Ranger output for example.


## Output is multiple summary exon and intron count files per sample. 
	+ Further summarization is to be perfomed in R. 
	+ I will poissibly update the snakemake to do this at some point.


