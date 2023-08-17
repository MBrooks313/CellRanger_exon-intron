
library(argparse)

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
    tmp_bar <- gsub(".+(CB:Z:.+-1).+", "\\1", oneLine)
    tmp_bar <- gsub(".+:", "", tmp_bar)
    tmp_type <- gsub(".+(RE:A:[NE]).+", "\\1", oneLine)
    tmp_type <- ifelse(tmp_type == "RE:A:E", "exon", "intron")
    tmp_bar_type <- paste(tmp_bar, tmp_type, sep = ",")
    write(tmp_bar_type, file = outfile, append=TRUE, sep = ",")
  }
  close(con)
}

# Run that function
processFile(xargs$input, xargs$output)
