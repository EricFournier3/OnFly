#!/bin/bash
BASE_DIR="/data/Runs/20191016_gono-16s-cloac/cloac/RESISTANCE/Abricate/SEARCH_ON_ALL_CONTIG/"
#BASE_DIR="/data/Runs/20191016_gono-16s-cloac/cloac/RESISTANCE/Abricate/SEARCH_ON_ALL_CONTIG/TEST/"


db_list=()

for spec_dir in $(ls -d ${BASE_DIR}*/)
 do
 spec=$(basename ${spec_dir})
 echo "To GFF for ${spec}"
 for db_dir in $(ls -d ${spec_dir}*/)
  do
  if [ -f ${db_dir}"res.tab" ] 
    then
    awk 'BEGIN{FS="\t"}NR>1{{split($2,myarr,"_")}{print "sequence-region "$2" 1 "myarr[4]}}' ${db_dir}"res.tab"  | csvtk -d ' ' -T uniq -f 2 >> ${spec_dir}"temp.gff" 2>/dev/null
    awk -v out="testing"   -f MakeGffAbricateSummaryUtil.awk  ${db_dir}"res.tab" >> ${spec_dir}temp2.gff

  fi
 done
csvtk -d ' ' -T uniq -f 1 ${spec_dir}temp.gff | sort  | uniq | sed 's/"//g;s/^/##/;1 i\##gff-version 3.2.1'  >> ${spec_dir}temp3.gff
cat ${spec_dir}temp3.gff ${spec_dir}temp2.gff > ${spec_dir}GffSummary.gff 
rm ${spec_dir}"temp"*
done

