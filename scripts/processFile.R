
library(argparse)
library(tidyverse)

# Arg parser for the command line input
parser <- ArgumentParser(description= 'Parse this arg!')

parser$add_argument('--input', '-i', help= 'I am the input file')
parser$add_argument('--output', '-o', help= 'I am the output file')

xargs<- parser$parse_args()


# Function to read in the file line-by-line and pull out the barcode and indicate of the read was an intron or exon read 
processFile = function(filepath, outfile){
  con = file(filepath, "r")
  while ( TRUE ) {
    oneLine = readLines(con, n = 1)
    if ( length(oneLine) == 0 ) {
      break
    }
    # Get barcode
    tmp_bar <- str_extract(pattern="CB:Z:.+-1", string=oneLine)
    tmp_bar <- gsub(".+:", "", tmp_bar)
    # Get gene
    tmp_gene <- str_extract(pattern="GN:Z:[[:alpha:][:digit:]]+", string=oneLine)
    tmp_gene <- gsub(".+:", "", tmp_gene)
    # Get read type
    tmp_type <- str_extract(pattern="RE:A:[NE]", string=oneLine)
    tmp_type <- ifelse(tmp_type == "RE:A:E", "exon", "intron")

    bar_gene_type <- paste(tmp_bar, tmp_gene, tmp_type, sep = ",")
    write(bar_gene_type, file = outfile, append=TRUE, sep = ",")
  }
  close(con)
}

# Run that function
processFile(xargs$input, xargs$output)
