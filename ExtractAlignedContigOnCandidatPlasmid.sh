#!/bin/bash
IN_FILE="/data/Runs/20191016_gono-16s-cloac/cloac/PLASMIDSEEKER/GVIEW/CandidatePlasmidsByPlasmid.txt"
#IN_FILE="/data/Runs/20191016_gono-16s-cloac/cloac/PLASMIDSEEKER/GVIEW/CandidatePlasmidsByPlasmid_test.txt"
BASEDIR_OUT="/data/Runs/20191016_gono-16s-cloac/cloac/PLASMIDSEEKER/"

while read plasmid cluster spec gviewstatus
  do
  echo "plasmid : ${plasmid} cluster : ${cluster} spec : ${spec}"
  
  out_base="${BASEDIR_OUT}${spec}/${cluster}/BLAST/"
  blastfile_in="${out_base}res_sort.tab"
  out="${out_base}AlignedContigsOn${plasmid}.txt"
  awk 'BEGIN{FS="\t"}'"/${plasmid}/"'{print $1"\t"$4"\t"$6}' ${blastfile_in} > $out 
  sed -i '1 i\Contig\tAlignmentLength\tContigStart' ${out}
  sed -i '1 i\'"${plasmid}" ${out}
done < $IN_FILE
