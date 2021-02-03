#!/bin/bash

kraken_out_dir="/data/Runs/20210112_RVOP2/rvop2/Kraken/"
fastq_dir="/data/Runs/20210112_RVOP2/rvop2/1_FASTQ_BRUT/"
#fastq_dir="/data/Runs/20210112_RVOP2/rvop2/TEST/"
KRAKENDB="/data/Databases/KRAKEN_DB"


for fastq in $(ls ${fastq_dir}*_R1_*.fastq.gz):
  do
  #echo $fastq
  spec_name=$(basename ${fastq})
  spec_name=$(echo $spec_name | cut -d '_' -f1)
  echo "Kraken on "$spec_name
  all_fastq=${fastq_dir}${spec_name}*"fastq.gz"
  #echo $all_fastq
  kraken_cmd="kraken2 --db ${KRAKENDB} --output ${kraken_out_dir}Out_${spec_name} --report ${kraken_out_dir}Report_${spec_name} --thread 30 <(zcat ${all_fastq})"
  #echo ${kraken_cmd}
  eval ${kraken_cmd}
done
