#!/bin/bash

BASE_DIR="/data/Runs/20191016_gono-16s-cloac/cloac/"
MLST_OUT=${BASE_DIR}"MLST/"
ASSEMBLY_IN=${BASE_DIR}"ASSEMBLAGE_SPADES/FILTRE/"

for assemb in $(ls ${ASSEMBLY_IN}*.fasta)
 do
 #echo ${assemb}
 SAMPLE_NAME=$(echo $(basename $assemb))
 SAMPLE_NAME=$(echo $SAMPLE_NAME | cut -d '_' -f 1)
 echo "Mlst on "${SAMPLE_NAME}
 mlst_cmd="mlst --scheme ecloacae --novel ${MLST_OUT}${SAMPLE_NAME}_newAllele.txt  --minid 100 --minscore 100  ${assemb}   1>${MLST_OUT}${SAMPLE_NAME}_Mlst.txt 2>&1"
 #echo "$mlst_cmd"
 eval $mlst_cmd
done

grep -P "ecloacae\t" ${MLST_OUT}*Mlst.txt > ${MLST_OUT}All_Mlst.txt

echo "End"
