#!/bin/bash

<<COM
TODO CNEG
TODO FLASH
TODO MAP SUR REFERENCE SEPAREMENT

flash -z -m 10 -o L00258931 -d . /data/Runs/20200514_ctrl-metag-16s-blasto/16s/3_FASTQ_CLEAN_TRIMMOMATIC/16S-L00258931-16S_R1_PAIR.fastq.gz /data/Runs/20200514_ctrl-metag-16s-blasto/16s/3_FASTQ_CLEAN_TRIMMOMATIC/16S-L00258931-16S_R2_PAIR.fastq.gz 2>&1 | tee L00258931_merge.log

L00258931.extendedFrags.fastq.gz
L00258931.notCombined_1.fastq.gz
L00258931.notCombined_2.fastq.gz


smalt index -k 20 -s 4 ref.fasta  ref.fasta

smalt map -f sam -l pe -i 500  -o res2.sam ref.fasta L00258931.notCombined_1.fastq.gz  L00258931.notCombined_2.fastq.gz
smalt map -f sam  -o res.sam ref.fasta L00258931.extendedFrags.fastq.gz

samtools view -bS res.sam > res.bam;samtools view -bS res2.sam  > res2.bam
samtools merge -h res.sam  out.bam res.bam  res2.bam


TODO CLEAN

COM

green_message="\e[32m"
white_message="\e[39m"
red_message="\e[31m"
yellow_message="\e[33m"


IDENTITY_THRESHOLD=0.95
MIN_BEDTOOLS_COV=10

base_dir="/data/Runs/20200514_ctrl-metag-16s-blasto/16s/8_MAP_ON_REF/"
base_dir_16s_ref="/data/Databases/16SrRNA/"

bact_16s_db=${base_dir_16s_ref}"bacteria.16SrRNA.fna"
human_16s_ref=${base_dir_16s_ref}"Human.fna"

fastq_dir="/data/Runs/20200514_ctrl-metag-16s-blasto/16s/3_FASTQ_CLEAN_TRIMMOMATIC/"
samples=("16S-L00258932-16S" "16S-L00258931-16S")

ref_list=('Burkholderia cepacia' 'Enterococcus faecium' 'Blautia hominis' 'Tyzzerella nexilis' 'Cutibacterium acnes' 'Halomonas salicampi')
ref_list_=()


get_ref(){
        
        echo -e "${green_message}INFO: " "Get reference"
	echo -e "${white_message}"

	for ref in "${ref_list[@]}"
	  do
	  ref_fasta=${ref/ /_}".fna"
	  seqkit grep -r -n -p  "${ref}" ${bact_16s_db} | seqkit head -n 1 >> ${ref_fasta}
	  ref_list_+=(${ref_fasta})
	done

	cp ${human_16s_ref} .

	ref_list_+=("Human.fna")

}


index_ref(){
  echo -e "${green_message}INFO: " "Index reference"
  echo -e "${white_message}"

  for ref in ${ref_list_[@]}
    do
    cmd_smalt_index="smalt index -k 20 -s 4 ${ref} ${ref}"
    eval ${cmd_smalt_index}
  done
}

merge_reads(){
  echo -e "${green_message}INFO: " "Merge reads"
  echo -e "${white_message}"
  
  for sample in ${samples[@]}
    do

    cmd_flash="/data/Applications/bin/flash -z -m 10 -o ${sample} -d . ${fastq_dir}${sample}_R1_PAIR.fastq.gz ${fastq_dir}${sample}_R2_PAIR.fastq.gz 2>&1 | tee ${sample}_merge.log"

   eval ${cmd_flash}

  done

}

map(){
  
  for sample in ${samples[@]}
    do

    for fasta_myref in ${ref_list_[@]}
      do
      
      prefix_myref=${fasta_myref/.fna/}

      echo -e "${green_message}INFO: " "Map ${sample} on ${prefix_myref}"
      echo -e "${white_message}"

      prefix_map="${sample}_on_${prefix_myref}"
      cmd_smalt_unpaired="smalt map -y $IDENTITY_THRESHOLD -f sam -o ${prefix_map}_unpaired.sam ${fasta_myref} ${sample}.extendedFrags.fastq.gz"
      eval ${cmd_smalt_unpaired}      


      cmd_smalt_paired="smalt map  -y $IDENTITY_THRESHOLD  -f sam -l pe -i 500 -o ${prefix_map}_paired.sam  ${sample}.notCombined_1.fastq.gz ${sample}.notCombined_2.fastq.gz" 
      eval ${cmd_smalt_paired}
       

      cmd_convert_sam2bam="samtools view -bS ${prefix_map}_unpaired.sam > ${prefix_map}_unpaired.bam;samtools view -bS ${prefix_map}_paired.sam > ${prefix_map}_paired.bam"
      eval ${cmd_convert_sam2bam}
      
      cmd_merge_bam="samtools merge -h ${prefix_map}_unpaired.sam ${prefix_map}_merge.bam ${prefix_map}_unpaired.bam ${prefix_map}_paired.bam"
      eval ${cmd_merge_bam}

      cmd_bam_sort="samtools sort ${prefix_map}_merge.bam ${prefix_map}_sort"
      eval ${cmd_bam_sort}

      cmd_bam_index="samtools index ${prefix_map}_merge_sort.bam"
      eval ${cmd_bam_index}

      MAPPED_READS=$(samtools view -c -F 260 ${prefix_map}_merge_sort.bam)
      TOTAL_READS=$(expr ${MAPPED_READS} + $(samtools view -c -f 4 ${prefix_map}_merge_sort.bam))
      PERCENT_MAP=$(echo "scale=4;(${MAPPED_READS}/${TOTAL_READS})*100" | bc -l)

      cmd_bedtools="bedtools genomecov -ibam ${prefix_map}_merge_sort.bam -bg | awk '\$4 > ${MIN_BEDTOOLS_COV}' | sort -n -k 4 > ${prefix_map}_bedgraph_sort_by_cov.txt; sort -n -k 3 ${prefix_map}_bedgraph_sort_by_cov.txt > ${prefix_map}_bedgraph_sort_by_position.txt"

      eval ${cmd_bedtools}

      echo -e "Identity threshold:\t${IDENTITY_THRESHOLD}\n" > ${prefix_map}_MAP_STAT.txt
      echo -e "Mapped:\t${MAPPED_READS}\nTotal:\t${TOTAL_READS}\nPercent:\t${PERCENT_MAP}" >> ${prefix_map}_MAP_STAT.txt

    done
  done    
}


clean(){

  clean *.sam *.fastq.gz  *_unpaired.bam *_paired.bam *_merge.bam

}

get_ref
index_ref
merge_reads
map
clean


echo -e "${green_message}INFO: " "Terminé"
echo -e "${white_message}"



















