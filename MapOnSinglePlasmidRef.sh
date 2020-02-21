#!/bin/bash
#FASTQ_TRIMMO_PATH="/data/Runs/20191016_gono-16s-cloac/cloac/3_FASTQ_CLEAN_TRIMMOMATIC/"
FASTQ_TRIMMO_PATH="/data/Runs/20191016_gono-16s-cloac/cloac/PLASMIDSEEKER/TEMP_FASTQ/"
PLASMID_DB_FILE="/data/Databases/PLASMIDSEEKER/plasmid_db_20200205.fna"
#SPEC_DIR="/data/Runs/20191016_gono-16s-cloac/cloac/PLASMIDSEEKER/"
SPEC_DIR="/data/Runs/20191016_gono-16s-cloac/cloac/PLASMIDSEEKER/TEMP_SPEC/"


#todo bedcov by pos et par cov et bam file pour IGV



declare -A acc_map
ref_L156115=("NZ_CP024813" "NC_024983")
ref_L170167=("NZ_CP024813" "NC_024983")
ref_L170648=("NZ_CP024813" "NC_024983")
ref_L170650=("NZ_CP024813" "NC_024983")
ref_L171985=("NZ_CP024813" "NC_024983")
ref_L173798=("NZ_CP024813" "NC_024983")
ref_L173805=("NZ_CP024813" "NC_024983")
ref_L174598=("NZ_CP024813" "NC_024983")
ref_L60126=("NZ_CP046261" "NZ_CP033629" "NZ_CP016389" "NZ_CP046273" "NZ_CP042504" "NZ_CP042498" "NZ_CP035389" "NZ_CP042576" "NZ_CP039507" "NZ_CP042492" "NZ_CP032846" "NZ_CP023906")
ref_L62570=("NZ_CP014006" "NZ_CP021534" "NZ_CP034957" "NZ_CP010389" "NZ_CP012166" "NZ_CP032846" "NZ_CP039507" "NZ_CP042492" "NZ_CP042498" "NZ_CP042504" "NZ_CP042555" "NZ_CP042576")


acc_map["L156115"]=${ref_L156115[@]}
<<COM
acc_map["L170167"]=${ref_L170167[@]}
acc_map["L170648"]=${ref_L170648[@]}
acc_map["L170650"]=${ref_L170650[@]}
acc_map["L171985"]=${ref_L171985[@]}
acc_map["L173798"]=${ref_L173798[@]}
acc_map["L173805"]=${ref_L173805[@]}
acc_map["L174598"]=${ref_L174598[@]}
acc_map["L60126"]=${ref_L60126[@]}
acc_map["L62570"]=${ref_L170167[@]}
COM


Map(){
 myspec=$1
 myacc=$2
 fastq_r1=${FASTQ_TRIMMO_PATH}${myspec}"_R1_PAIR.fastq.gz"
 fastq_r2=${FASTQ_TRIMMO_PATH}${myspec}"_R2_PAIR.fastq.gz"
 out_dir="${SPEC_DIR}MapOnSingleRef/"
 echo "R1 "${fastq_r1}
 echo "OUT ${out_dir}"
 if [[ ! -d ${out_dir}${myacc} ]]
  then
  mkdir -p $out_dir ${out_dir}${myacc}
 else
  echo "Dir exist"
 fi
 #seqkit grep -n -r -p "${seq_desc}" ${PLASMID_DB_FILE} >>  ${BASEDIR_OUT}${sample}"/"${cluster}"/PlasmidRef.fasta"	
 

}



for spec in  ${!acc_map[@]}
 do
 echo "Work on $spec "
 for acc in  ${acc_map[$spec]}
  do
  echo "Map on  $acc "
  Map $spec $acc
 done

done
