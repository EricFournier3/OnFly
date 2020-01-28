#!/bin/bash
#FASTQ_DIR="/data/Runs/20191016_gono-16s-cloac/cloac/3_FASTQ_CLEAN_TRIMMOMATIC/"
FASTQ_DIR="/data/Runs/20191016_gono-16s-cloac/cloac/3_FASTQ_CLEAN_TRIMMOMATIC/TEMP/"
BASE_OUT="/data/Runs/20191016_gono-16s-cloac/cloac/PLASMID_FILTERED_ASSEMBLY/"
PLASMIDSPADES_OUT=${BASE_OUT}"PLASMIDSPADES_OUT/"
MAP_ON_PLASMID_OUT=${BASE_OUT}"MAP_ON_PLASMID_OUT/"
SPADES_OUT=${BASE_OUT}"SPADES_OUT/"
QUAST_OUT=${SPADES_OUT}"QUAST/"

PLASMID_SPADES_EXEC="/data/Applications/Spades/SPAdes-3.13.1-Linux/bin/plasmidspades.py "

E_CLOAC_REF="/data/Databases/QUAST_REF/GCA_000783675.2_ASM78367v2_genomic.fna"


for fastq in $(ls ${FASTQ_DIR}*R1_PAIR.fastq.gz)
 do
 #echo "$fastq"
 SAMPLE_NAME=$(echo $(basename $fastq))
 SAMPLE_NAME=$(echo $SAMPLE_NAME | cut -d '_' -f 1)
 echo ">>>  PlasmidSpades on ${SAMPLE_NAME}"
 PAIR_R1=$fastq
 PAIR_R2=${PAIR_R1/_R1_PAIR.fastq.gz/_R2_PAIR.fastq.gz}
 
 UNPAIR_R1=${PAIR_R1/_R1_PAIR.fastq.gz/_R1_UNPAIR.fastq.gz}
 UNPAIR_R2=${PAIR_R2/_R2_PAIR.fastq.gz/_R2_UNPAIR.fastq.gz}

 plasmid_spades_cmd="${PLASMID_SPADES_EXEC} --pe1-1 ${PAIR_R1} --pe1-2 ${PAIR_R2} --pe1-s ${UNPAIR_R1} --pe1-s ${UNPAIR_R2} -m 200 -k 77,99,127 --careful -t 30 -o ${PLASMIDSPADES_OUT}${SAMPLE_NAME} >/dev/null"
 #echo ">>> plasmid_spades_cmd $plasmid_spades_cmd"
 eval $plasmid_spades_cmd
 exit
 echo ">>>  Smalt on ${SAMPLE_NAME}"
 MAP_OUT=${MAP_ON_PLASMID_OUT}${SAMPLE_NAME}/
 #mkdir $MAP_OUT
 ref=${PLASMIDSPADES_OUT}${SAMPLE_NAME}"/contigs.fasta"
 
 ref_index_cmd="smalt index -k 20 -s 4 ${ref} ${ref}"
 #echo ">>>ref_index_cmd $ref_index_cmd"
 #eval $ref_index_cmd

 map_cmd="smalt map -f sam -l pe -i 500 -o ${MAP_OUT}out_map.sam ${ref} ${PAIR_R1} ${PAIR_R2} >/dev/null"
 #echo ">>>map_cmd $map_cmd"
 #eval $map_cmd
 

 sam_to_bam_cmd="samtools view -bS ${MAP_OUT}out_map.sam > ${MAP_OUT}out_map.bam" 
 #echo ">>>sam_to_bam_cmd $sam_to_bam_cmd"
 #eval $sam_to_bam_cmd

 extract_unmap_cmd="samtools view -f 4 ${MAP_OUT}out_map.bam > ${MAP_OUT}out_unmap.sam" 
 #echo ">>>extract_unmap_cmd $extract_unmap_cmd"
 #eval $extract_unmap_cmd

 sam_to_bam_cmd="samtools view -bS ${MAP_OUT}out_unmap.sam > ${MAP_OUT}out_unmap.bam"
 #eval $sam_to_bam_cmd

 bam_sort_cmd="samtools sort ${MAP_OUT}out_unmap.bam ${MAP_OUT}out_unmap_sort"
 #echo ">>>bam_sort_cmd $bam_sort_cmd"
 #eval $bam_sort_cmd
 
 bam_index_cmd="samtools index  ${MAP_OUT}out_unmap_sort.bam"
 #echo ">>>bam_index_cmd $bam_index_cmd"
 #eval $bam_index_cmd

 extract_paired_fastq_cmd="bedtools bamtofastq -i ${MAP_OUT}out_unmap_sort.bam -fq ${MAP_OUT}${SAMPLE_NAME}_R1.fastq -fq2 ${MAP_OUT}${SAMPLE_NAME}_R2.fastq 2>/dev/null"
 #echo ">>>extract_paired_fastq_cmd $extract_paired_fastq_cmd"
 #eval $extract_paired_fastq_cmd

 GENOMIC_FASTQ_STAT_OUT="${MAP_OUT}FastqStat.txt"
 fastq_stat_cmd="seqkit stats ${MAP_OUT}*.fastq -T -a | csvtk pretty -t > ${GENOMIC_FASTQ_STAT_OUT}" 
 #echo ">>>fastq_stat_cmd $fastq_stat_cmd"
 #eval  $fastq_stat_cmd

 echo ">>> zip fastq for ${SAMPLE_NAME}"
 zip_cmd="gzip ${MAP_OUT}${SAMPLE_NAME}_R1.fastq ${MAP_OUT}${SAMPLE_NAME}_R2.fastq"
 #echo ">>>zip_cmd $zip_cmd" 
 #eval $zip_cmd

 echo ">>> Spades on ${SAMPLE_NAME}"
 spades_cmd="spades.py --pe1-1 ${MAP_OUT}${SAMPLE_NAME}_R1.fastq.gz  --pe1-2 ${MAP_OUT}${SAMPLE_NAME}_R2.fastq.gz  -m 200 -k 77,99,127 --careful -t 30 -o ${SPADES_OUT}${SAMPLE_NAME} >/dev/null"
 #echo ">>>spades_cmd $spades_cmd"
 #eval $spades_cmd

 #echo ">>>contig_filter_cmd $contig_filter_cmd"
 #seqkit fx2tab ${SPADES_OUT}${SAMPLE_NAME}/contigs.fasta | awk -v min_l=1000 'BEGIN{FS="_"}{if($4>=min_l){print $0}}' | seqkit tab2fx > ${SPADES_OUT}${SAMPLE_NAME}/contigs_filtered.fasta

 echo ">>> Quast on ${SAMPLE_NAME}"
 quast_cmd="quast -o ${QUAST_OUT}${SAMPLE_NAME} -r ${E_CLOAC_REF} --glimmer --conserved-genes-finding -t 40 ${SPADES_OUT}${SAMPLE_NAME}/contigs_filtered.fasta >/dev/null"
 #echo ">>>quast_cmd $quast_cmd"
 #eval $quast_cmd
 
 #cp ${PLASMIDSPADES_OUT}${SAMPLE_NAME}"/contigs.fasta" ${PLASMIDSPADES_OUT}${SAMPLE_NAME}".fasta"
 #cp ${SPADES_OUT}${SAMPLE_NAME}"/contigs.fasta" ${SPADES_OUT}${SAMPLE_NAME}".fasta"

 #rm ${MAP_OUT}*".sam" ${MAP_OUT}*".fastq.gz" ${MAP_OUT}*"unmap_sort"*
 #rm -r ${SPADES_OUT}${SAMPLE_NAME}
 #rm -r ${PLASMIDSPADES_OUT}${SAMPLE_NAME}
 
done

echo "Quast All"
all_quast_cmd="quast -o ${SPADES_OUT}QUAST_ALL/ -t 40 ${SPADES_OUT}*.fasta 1>/dev/null"
#eval $all_quast_cmd
