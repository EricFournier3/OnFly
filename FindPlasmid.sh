#!/bin/bash

SPADES_ASSEMBLY_IN="/data/Runs/20191016_gono-16s-cloac/cloac/ASSEMBLAGE_SPADES/FILTRE/"
PLASMIDSPADES_ASSEMBLY_IN="/data/Runs/20191016_gono-16s-cloac/cloac/PLASMID_FILTERED_ASSEMBLY/PLASMIDSPADES_OUT/"
SPADES_ASSEMBLY_PLASMIDFILTERED_IN="/data/Runs/20191016_gono-16s-cloac/cloac/PLASMID_FILTERED_ASSEMBLY/SPADES_OUT/"

PLASMIDFINDER_OUT="/data/Runs/20191016_gono-16s-cloac/cloac/PLASMID_FINDER/"

echo -e ">>> Search on spades assembly\n"

for fasta in $(ls ${SPADES_ASSEMBLY_IN}*.fasta)
 do
 SAMPLE_NAME=$(echo $(basename $fasta))
 SAMPLE_NAME=$(echo $SAMPLE_NAME | cut -d '_' -f 1)
 OUT=${PLASMIDFINDER_OUT}${SAMPLE_NAME}"/SEARCH_ON_ALL_CONTIG"
 mkdir -p $OUT

 plasmidfinder_cmd="plasmidfinder.py -i ${fasta} -o ${OUT} -x 1>/dev/null 2>&1"
 echo $plasmidfinder_cmd
 eval $plasmidfinder_cmd
done

echo -e ">>> Search on plasmidspades assembly\n"

for fasta in $(ls ${PLASMIDSPADES_ASSEMBLY_IN}*.fasta)
 do
 SAMPLE_NAME=$(echo $(basename $fasta))
 SAMPLE_NAME=$(echo $SAMPLE_NAME | cut -d '.' -f 1)
 OUT=${PLASMIDFINDER_OUT}${SAMPLE_NAME}"/SEARCH_ON_PLASMID_CONTIG"
 mkdir -p $OUT

 plasmidfinder_cmd="plasmidfinder.py -i ${fasta} -o ${OUT} -x 1>/dev/null 2>&1"
 echo $plasmidfinder_cmd
 eval $plasmidfinder_cmd
done

echo -e ">>> Search on plasmid filtered assembly\n"

for fasta in $(ls ${SPADES_ASSEMBLY_PLASMIDFILTERED_IN}*.fasta)
 do
 SAMPLE_NAME=$(echo $(basename $fasta))
 SAMPLE_NAME=$(echo $SAMPLE_NAME | cut -d '.' -f 1)
 OUT=${PLASMIDFINDER_OUT}${SAMPLE_NAME}"/SEARCH_ON_NOPLASMID_CONTIG"
 mkdir -p $OUT

 plasmidfinder_cmd="plasmidfinder.py -i ${fasta} -o ${OUT} -x 1>/dev/null 2>&1"
 echo $plasmidfinder_cmd
 eval $plasmidfinder_cmd
done


