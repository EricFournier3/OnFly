#!/bin/bash

SPADES_ASSEMBLY_IN="/data/Runs/20191016_gono-16s-cloac/cloac/ASSEMBLAGE_SPADES/FILTRE/"
PLASMIDSPADES_ASSEMBLY_IN="/data/Runs/20191016_gono-16s-cloac/cloac/PLASMID_FILTERED_ASSEMBLY/PLASMIDSPADES_OUT/"
SPADES_ASSEMBLY_PLASMIDFILTERED_IN="/data/Runs/20191016_gono-16s-cloac/cloac/PLASMID_FILTERED_ASSEMBLY/SPADES_OUT/"

ABRICATE_OUT="/data/Runs/20191016_gono-16s-cloac/cloac/RESISTANCE/Abricate/"

db_list=("card" "argannot" "ncbi" "plasmidfinder" "resfinder" "vfdb")

#echo ${db_list[@]}

echo -e ">>> Search on spades assembly\n"

for fasta in  $(ls ${SPADES_ASSEMBLY_IN}*.fasta)
 do 
 SAMPLE_NAME=$(echo $(basename $fasta))
 SAMPLE_NAME=$(echo $SAMPLE_NAME | cut -d '_' -f 1)
 OUT_SAMPLE=${ABRICATE_OUT}"SEARCH_ON_ALL_CONTIG/${SAMPLE_NAME}/"
 for db in ${db_list[@]}
  do
  echo "db is ${db}"
  OUT=${OUT_SAMPLE}${db}"/"
  mkdir -p $OUT 
  abricate_cmd="abricate --thread 8 --db $db $fasta > ${OUT}res.tab"
  eval $abricate_cmd
  sudo chmod 777 ${OUT}res.tab
 done
 
done


for db in ${db_list[@]}
  do
  IN="${ABRICATE_OUT}SEARCH_ON_ALL_CONTIG/*/${db}/res.tab"
  $echo $IN
  OUT=${ABRICATE_OUT}"SEARCH_ON_ALL_CONTIG/"
  abricate_summary_cmd="abricate --summary ${IN} > ${OUT}summary_${db}.txt"
  #echo $abricate_summary_cmd
  eval $abricate_summary_cmd

done

echo -e ">>> Search on plasmidspades assembly\n"

for fasta in  $(ls ${PLASMIDSPADES_ASSEMBLY_IN}*.fasta)
 do 
 SAMPLE_NAME=$(echo $(basename $fasta))
 SAMPLE_NAME=$(echo $SAMPLE_NAME | cut -d '.' -f 1)
 OUT_SAMPLE=${ABRICATE_OUT}"SEARCH_ON_PLASMID_CONTIG/${SAMPLE_NAME}/"

 for db in ${db_list[@]}
  do
  OUT=${OUT_SAMPLE}${db}"/"
  mkdir -p $OUT 
  abricate_cmd="abricate --thread 8 --db $db $fasta > ${OUT}res.tab"
  #echo $abricate_cmd
  eval $abricate_cmd
  sudo chmod 777 ${OUT}res.tab
 done
 
done

for db in ${db_list[@]}
  do
  IN="${ABRICATE_OUT}SEARCH_ON_PLASMID_CONTIG/*/${db}/res.tab"
  $echo $IN
  OUT=${ABRICATE_OUT}"SEARCH_ON_PLASMID_CONTIG/"
  abricate_summary_cmd="abricate --summary ${IN} > ${OUT}summary_${db}.txt"
  #echo $abricate_summary_cmd
  eval $abricate_summary_cmd

done

echo -e ">>> Search on plasmid filtered assembly\n"

for fasta in  $(ls ${SPADES_ASSEMBLY_PLASMIDFILTERED_IN}*.fasta)
 do 
 SAMPLE_NAME=$(echo $(basename $fasta))
 SAMPLE_NAME=$(echo $SAMPLE_NAME | cut -d '.' -f 1)
 OUT_SAMPLE=${ABRICATE_OUT}"SEARCH_ON_NOPLASMID_CONTIG/${SAMPLE_NAME}/"

 for db in ${db_list[@]}
  do
  OUT=${OUT_SAMPLE}${db}"/"
  mkdir -p $OUT 
  abricate_cmd="abricate --thread 8 --db $db $fasta > ${OUT}res.tab"
  #echo $abricate_cmd
  eval $abricate_cmd
  sudo chmod 777 ${OUT}res.tab
 done
 
done

for db in ${db_list[@]}
  do
  IN="${ABRICATE_OUT}SEARCH_ON_NOPLASMID_CONTIG/*/${db}/res.tab"
  $echo $IN
  OUT=${ABRICATE_OUT}"SEARCH_ON_NOPLASMID_CONTIG/"
  abricate_summary_cmd="abricate --summary ${IN} > ${OUT}summary_${db}.txt"
  #echo $abricate_summary_cmd
  eval $abricate_summary_cmd

done



