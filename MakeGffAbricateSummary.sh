#!/bin/bash
#BASE_DIR="/data/Runs/20191016_gono-16s-cloac/cloac/RESISTANCE/Abricate/SEARCH_ON_ALL_CONTIG/"
BASE_DIR="/data/Runs/20191016_gono-16s-cloac/cloac/RESISTANCE/Abricate/SEARCH_ON_ALL_CONTIG/TEST/"


#awk 'BEGIN{FS="\t"};{sub(/length/,"eric",$2)};{print $2}' res.tab 
#awk 'BEGIN{FS="\t"};NR>1{print $2"\t"$12"\tgene\t"$3"\t"$4"\t"$11"\t"$5"\t1\tID="$13";Name="$6";cov="$10}' res.tab > test.gff
##gff-version 3.2.1
##sequence-region NODE_26_length_6049_cov_22.965721 1 6049
##sequence-region NODE_28_length_5544_cov_15.450618 1 5544
##sequence-region NODE_2_length_596009_cov_24.491384 1 596009
##sequence-region NODE_30_length_3972_cov_26.823147 1 3972
##sequence-region NODE_32_length_2378_cov_27.244780 1 2378
##sequence-region NODE_33_length_1731_cov_20.218828 1 1731
##sequence-region NODE_34_length_1384_cov_24.068417 1 1384
##sequence-region NODE_35_length_1316_cov_30.848612 1 1316
##sequence-region NODE_4_length_500773_cov_24.781990 1 500773

#awk 'BEGIN{print "allo";FS="\t"};NR>1{split($2,myarr,"_")};{print myarr[4]}' res.tab
#awk 'BEGIN{print "##gff-version 3.2.1";FS="\t"}NR>1{{split($2,myarr,"_")}{print "##sequence-region "$2" 1 "myarr[4]}}' res.tab | uniq

#awk 'BEGIN{print "##gff-version 3.2.1";FS="\t"}NR>1{{split($2,myarr,"_")}{print "##sequence-region "$2" 1 "myarr[4]}}' res.tab | uniq >test.gff;awk 'BEGIN{FS="\t"};NR>1{print $2"\t"$12"\tgene\t"$3"\t"$4"\t"$11"\t"$5"\t1\tID="$13";Name="$6";cov="$10}' res.tab >> test.gff

#awk 'NR>1{{split($2,myarr,"_")}{print "sequence-region "$2" 1 "myarr[4]}}' res.tab  | csvtk -d ' ' -T uniq -f 2


#awk 'BEGIN{FS="\t"}NR>1{{split($2,myarr,"_")}{print "sequence-region "$2" 1 "myarr[4]}}' res.tab  | csvtk -d ' ' -T uniq -f 2

db_list=()

for spec_dir in $(ls -d ${BASE_DIR}*/)
 do
 echo "Spec dir is ${spec_dir}"
 for db_dir in $(ls -d ${spec_dir}*/)
  do
  #echo "Db dir is ${db_dir}"
  #echo $(basename ${db_dir})
  if [ -f ${db_dir}"res.tab" ] 
    then
    awk 'BEGIN{FS="\t"}NR>1{{split($2,myarr,"_")}{print "sequence-region "$2" 1 "myarr[4]}}' ${db_dir}"res.tab"  | csvtk -d ' ' -T uniq -f 2 >> ${BASE_DIR}"temp.gff" 2>/dev/null
    #awk 'BEGIN{FS="\t"};NR>1{{if(length($15)> 2){$15=$15;split($15,antibio_name_arr,";");antibio_name=antibio_name_arr[length(antibio_name_arr)]}else{antibio_name="NA"}}{print $2"\t"$12"\tgene\t"$3"\t"$4"\t"$11"\t"$5"\t1\tID="$13"-"NR";Name="$6";cov="$10";antibio="antibio_name}}' ${db_dir}"res.tab" >> ${BASE_DIR}temp2.gff
    awk 'BEGIN{FS="\t"};NR>1{{if(length($15)> 2){$15=$15;if(index($15;";")){split($15,antibio_name_arr,";")}else{split($15,antibio_name_arr,"/")};antibio_name=antibio_name_arr[length(antibio_name_arr)]}else{antibio_name="NA"}}{print $2"\t"$12"\tgene\t"$3"\t"$4"\t"$11"\t"$5"\t1\tID="$13"-"NR";Name="$6";cov="$10";antibio="antibio_name}}' ${db_dir}"res.tab" >> ${BASE_DIR}temp2.gff
   awk -v out="testing"   -f CreateGff.awk  ${db_dir}"res.tab" >> ${BASE_DIR}temp2.gff

  fi
 done
done

#csvtk -d ' ' -T uniq -f 1 ${BASE_DIR}temp.gff | sort  | uniq | sed 's/"//g;s/^/##/;1 i\##gff-version 3.2.1'  >> ${BASE_DIR}temp3.gff
#cat ${BASE_DIR}temp3.gff ${BASE_DIR}temp2.gff > ${BASE_DIR}final.gff 
