#!/bin/bash

BASE_DIR="/data/Runs/20191016_gono-16s-cloac/cloac/RESISTANCE/Abricate/"

echo -e "SPECIMEN\tTYPE\tGENE\tCOVERAGE\t%COVERAGE\t%IDENTITY\tDATABASE\tACCESSION\tPRODUCT\tRESISTANCE" > ${BASE_DIR}"SummaryTemp.txt"

declare -A type_arr
type_arr[SEARCH_ON_ALL_CONTIG]="GENOMIC_PLASMID"
type_arr[SEARCH_ON_NOPLASMID_CONTIG]="GENOMIC"
type_arr[SEARCH_ON_PLASMID_CONTIG]="PLASMID"

for subdir_name in ${!type_arr[@]}
 do 
 type=${type_arr[${subdir_name}]}

 for spec_dir in $(ls -d ${BASE_DIR}${subdir_name}/*/)
  do
  spec=$(echo $(basename $spec_dir))
  for bd in $(ls -d ${spec_dir}*/)
   do
   bd_name=$(echo $(basename ${bd}))
   res_file=${bd}"res.tab"

   nb_line=$(awk 'END{print NR}' ${res_file})
   
   if [ $nb_line -ne 1 ]
    then
     #echo "NB LINE IN $res_file IS ${nb_line}"
     #awk -v myspec=$spec -v mytype=$type 'BEGIN{FS="\t";type=mytype};NR==1{print "SPECIMEN\t"$6"\t"$7"\tTYPE"};NR>1{print myspec"\t"$6"\t"$7"\t"type}' ${res_file}
     awk -v myspec=$spec -v mytype=$type 'BEGIN{FS="\t";type=mytype};NR>1{print myspec"\t"mytype"\t"$6"\t"$7"\t"$10"\t"$11"\t"$12"\t"$13"\t"$14"\t"$15}' ${res_file} >> ${BASE_DIR}"SummaryTemp.txt"
   else
     echo -e "${spec}\t${type}\tNA\tNA\tNA\tNA\t${bd_name}\tNA\tNA\tNA" >> ${BASE_DIR}"SummaryTemp.txt"
   fi
  done
 done
done

awk 'NR==1{print $0}' ${BASE_DIR}"SummaryTemp.txt" > ${BASE_DIR}"SummaryResistance.txt"
awk 'NR>1{print $0}' ${BASE_DIR}"SummaryTemp.txt" | sort -k1,1 -k2,2 -k 7,7 >> ${BASE_DIR}"SummaryResistance.txt"
rm ${BASE_DIR}"SummaryTemp.txt"
