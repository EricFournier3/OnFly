#!/bin/bash


IDENTITY_THRESHOLD=0.80
MIN_BEDTOOLS_COV=10
C_NEG=""

out_dir="/data/Runs/20191016_gono-16s-cloac/cloac/MAP_ON_GENOMIC_REF/"
fastq_dir="/data/Runs/20191016_gono-16s-cloac/cloac/3_FASTQ_CLEAN_TRIMMOMATIC/"
spec_list_file="/data/Runs/20191016_gono-16s-cloac/cloac/ID_list.txt"
#spec_list_file="/data/Runs/20191016_gono-16s-cloac/cloac/3_FASTQ_CLEAN_TRIMMOMATIC/TEMP/ID_list.txt"
ref_dir="/data/Databases/QUAST_REF/"

ref_list=("Enterobacter_bugandensis_NZ_CP039453.fna" "Enterobacter_cloacae_CP026975.fna" "Enterobacter_hormaechei_NZ_CP027142.fna")


IndexRef(){
  cmd_index="smalt index -k 20 -s 4 $1 $1 > /dev/null"
  echo $cmd_index
  eval ${cmd_index}
}


for ref in ${ref_list[@]}
  do
  ref_path=${ref_dir}${ref}
  #echo "ref is ${ref_path}"
  IndexRef ${ref_path}
done


spec_list=()

while read spec_name
  do
  #echo "spec is "${spec_name}
  spec_list+=(${spec_name})
done < ${spec_list_file}



for spec in ${spec_list[@]}
  do
  fastq_r1=${fastq_dir}${spec}"_R1_PAIR.fastq.gz"
  fastq_r2=${fastq_dir}${spec}"_R2_PAIR.fastq.gz"

  for ref in ${ref_list[@]}
   do
   ref_name=${ref/.fna/}
   echo "********************  Map ${spec} on ${ref_name}"
   prefix_map=${out_dir}${spec}"_ON_"${ref_name}
   cmd_map="smalt map -f sam -l pe -y ${IDENTITY_THRESHOLD} -i 500 -o ${prefix_map}.sam ${ref_dir}${ref} ${fastq_r1} ${fastq_r2}"
   eval ${cmd_map}

   cmd_convert_to_bam="samtools view -bS ${prefix_map}.sam > ${prefix_map}.bam"
   eval ${cmd_convert_to_bam}

   cmd_bam_sort="samtools sort ${prefix_map}.bam ${prefix_map}_sort"
   eval ${cmd_bam_sort}

   cmd_bam_index="samtools index ${prefix_map}_sort.bam"
   eval ${cmd_bam_index}

   MAPPED_READS=$(samtools view -c -F 260 ${prefix_map}.bam)
   TOTAL_READS=$(expr ${MAPPED_READS} + $(samtools view -c -f 4 ${prefix_map}.bam))
   PERCENT_MAP=$(echo "scale=4;(${MAPPED_READS}/${TOTAL_READS})*100" | bc -l)

   cmd_bedtools="bedtools genomecov -ibam ${prefix_map}_sort.bam -bg | awk '\$4 > ${MIN_BEDTOOLS_COV}' | sort -n -k 4 > ${prefix_map}_bedgraph_sort_by_cov.txt; sort -n -k 3 ${prefix_map}_bedgraph_sort_by_cov.txt > ${prefix_map}_bedgraph_sort_by_position.txt "
   eval ${cmd_bedtools} 

   echo -e "Identity threshold:\t${IDENTITY_THRESHOLD}\n" > ${prefix_map}_MAP_STAT.txt
   echo -e "Mapped:\t${MAPPED_READS}\nTotal:\t${TOTAL_READS}\nPercent:\t${PERCENT_MAP}" >> ${prefix_map}_MAP_STAT.txt


    rm ${prefix_map}.sam  ${prefix_map}.bam
  done 

done

exit 1

