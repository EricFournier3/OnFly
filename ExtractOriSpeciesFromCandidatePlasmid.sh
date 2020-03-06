#!/bin/bash
db_file="/data/Databases/PLASMIDSEEKER/plasmid_db_20200205.fna"
IN_FILE="/data/Runs/20191016_gono-16s-cloac/cloac/PLASMIDSEEKER/GVIEW/CandidatePlasmidsByPlasmid.txt"
OUT_FILE="/data/Runs/20191016_gono-16s-cloac/cloac/PLASMIDSEEKER/GVIEW/CandidatePlasmidSpecies.txt"
OUT_FILE_SORT_BY_SPECIES="/data/Runs/20191016_gono-16s-cloac/cloac/PLASMIDSEEKER/GVIEW/CandidatePlasmidSpeciesSortBySpecies.txt"

plasmid_arr=()

while read plasmid cluster spec gviewstatus
  do
  if [[ ! ${plasmid_arr[@]} =~ "${plasmid}" ]]
    then
    plasmid_arr+=(${plasmid})
  fi

done < $IN_FILE

#echo ${plasmid_arr[@]}

#plasmid_arr=("CP029245" "CP034847")


for plasmid_acc in ${plasmid_arr[@]}
  do
  echo ${plasmid_acc}
  awk -v acc=${plasmid_acc} "/$plasmid_acc/"'{print acc"\t"$0"\t"$2"\t"$3}' ${db_file}  >> ${OUT_FILE}
  
done

sort -k 3 ${OUT_FILE} > ${OUT_FILE_SORT_BY_SPECIES}
