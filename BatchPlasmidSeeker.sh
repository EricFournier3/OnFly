#!/bin/bash
FASTQ_TRIMMO_PATH="/data/Runs/20191016_gono-16s-cloac/cloac/3_FASTQ_CLEAN_TRIMMOMATIC/"
#FASTQ_TRIMMO_PATH="/data/Runs/20191016_gono-16s-cloac/cloac/PLASMIDSEEKER/TEMP_FASTQ/"
BASEDIR_OUT="/data/Runs/20191016_gono-16s-cloac/cloac/PLASMIDSEEKER/"
EXEC="perl /data/Applications/PlasmidSeeker/PlasmidSeeker/plasmidseeker.pl"
DB="/data/Databases/PLASMIDSEEKER/plasmid_db/"
REF="/data/Databases/PLASMIDSEEKER/EcloacGenomeCP020089.fasta"
PLASMID_DB_FILE="/data/Databases/PLASMIDSEEKER/plasmid_db_20200205.fna"
PLASMID_BLAST_DB="/data/Databases/PLASMIDSEEKER/blast_plasmid_db_20200205"

#filter contig
#TODO blast des contig filter sur /data/Databases/PLASMIDSEEKER/blast_plasmid_db_20200205 
#blastn -query NODE_1.fasta  -db /data/Databases/PLASMIDSEEKER/blast_plasmid_db_20200205 -html -num_alignments 5 -num_descriptions 5 -out res_blast.html

#TODO REMOVE FASTQ

BlastPlasmid(){
	   base_dir=$1
	   blast_dir=${base_dir}"BLAST/"
	   mkdir ${blast_dir}
	   blast_cmd="blastn -query ${base_dir}SPADES/contigs_filtered.fasta -db ${PLASMID_BLAST_DB} -html -num_alignments 2 -num_descriptions 5 -out ${blast_dir}res.html"
	   eval $blast_cmd
}


AssembPlasmid(){
	sample=$1
	
	for cluster_dir in $(ls -d ${BASEDIR_OUT}${sample}"/Cluster_"*"/")
         do
         echo ">>>>>>>>>> ${cluster_dir} Assembly"
	 spades_out=${cluster_dir}"SPADES/"
	 spades_cmd="spades.py --pe1-1 ${cluster_dir}PlasmidReads_R1.fastq.gz --pe1-2 ${cluster_dir}PlasmidReads_R2.fastq.gz -m 200 -k 77,99,127 --careful -t 30 -o ${cluster_dir}SPADES >/dev/null"
         eval $spades_cmd
	 rm ${cluster_dir}PlasmidReads_R1.fastq.gz ${cluster_dir}PlasmidReads_R2.fastq.gz
         if [ -f ${cluster_dir}SPADES/contigs.fasta ]
	  then
	  seqkit fx2tab ${cluster_dir}SPADES/contigs.fasta | awk -v min_l=3000 'BEGIN{FS="_"}{if($4>=min_l){print $0}}' | seqkit tab2fx > ${cluster_dir}SPADES/contigs_filtered.fasta 2>/dev/null
	  
          state=$?
	  #echo "State is ${state}"
	  if [ $state -ne 0 ]
	   then
	   echo "No plasmid contig over 2999bp"
	  else
	   BlastPlasmid $cluster_dir
	  fi
	 fi
	done
}



MapOnPlasmid(){
	sample=$1
	
	for cluster_dir in $(ls -d ${BASEDIR_OUT}${sample}"/Cluster_"*"/")
	 do
	 echo ">>>>>>>>>>>> ${cluster_dir} Mapping" 
	 plasmid_ref=${cluster_dir}"PlasmidRef.fasta"
	 echo "Plasmid ref is ${plasmid_ref}"
	 ref_index_cmd="smalt index -k 20 -s 4 ${plasmid_ref} ${plasmid_ref}"
	 eval ${ref_index_cmd} 
	 fastq_r1=${FASTQ_TRIMMO_PATH}${sample}"_R1_PAIR.fastq.gz"
	 fastq_r2=${FASTQ_TRIMMO_PATH}${sample}"_R2_PAIR.fastq.gz"
         map_cmd="smalt map -f sam -l pe -y 0.80 -i 700 -o ${cluster_dir}out_map.sam ${plasmid_ref} ${fastq_r1} ${fastq_r2} >/dev/null"
         eval $map_cmd
	 sam_to_bam_cmd="samtools view -bS ${cluster_dir}out_map.sam > ${cluster_dir}out_map.bam"
	 eval $sam_to_bam_cmd
         extract_onlymap_cmd="samtools view -b -F 260 ${cluster_dir}out_map.bam > ${cluster_dir}out_onlymap.bam"
	 eval $extract_onlymap_cmd
	 bam_sort_cmd="samtools sort ${cluster_dir}out_onlymap.bam ${cluster_dir}out_onlymap_sort"
	 eval $bam_sort_cmd
	 bam_index_cmd="samtools index ${cluster_dir}out_onlymap_sort.bam"
	 eval $bam_index_cmd
	 extract_paired_fastq_cmd="bedtools bamtofastq -i ${cluster_dir}out_onlymap_sort.bam -fq ${cluster_dir}PlasmidReads_R1.fastq -fq2 ${cluster_dir}PlasmidReads_R2.fastq 2>/dev/null"
	 eval $extract_paired_fastq_cmd
	 fastq_stat_file=${cluster_dir}FastqStat.txt
	 fastq_stat_cmd="seqkit stats ${cluster_dir}*.fastq -T -a | csvtk pretty -t > ${fastq_stat_file}"
	 eval $fastq_stat_cmd
  	 zip_cmd="gzip ${cluster_dir}PlasmidReads_R1.fastq ${cluster_dir}PlasmidReads_R2.fastq"	 
	 eval $zip_cmd
	 rm ${cluster_dir}{out_map.bam,out_map.sam,out_onlymap.bam}
	done

}

ExtractPlamidicReads(){
        sample=$1
        res_file=${BASEDIR_OUT}${sample}"/out.txt"
	
	while read line
	 do
	 if [[ "$line" =~ "PLASMID CLUSTER" ]]
	   then
	   cluster=""
	   cluster=${line#PLASMID CLUSTER }
	   cluster="Cluster_"${cluster}
	   #echo "Cluster is ${cluster}"
	   mkdir ${BASEDIR_OUT}${sample}"/"${cluster}
	   spades_out=${BASEDIR_OUT}${sample}"/"${cluster}"/SPADES/"
	   mkdir $spades_out
	 elif [[ ! "$line" =~ "PLASMID CLUSTER" ]]
	  then
	  #echo "HIT IS $line"
          seq_desc=""
	  seq_desc=$line
	  seq_desc=${seq_desc/>/}
	  #echo "Seq desc is ${seq_desc}"
	  seqkit grep -n -r -p "${seq_desc}" ${PLASMID_DB_FILE} >>  ${BASEDIR_OUT}${sample}"/"${cluster}"/PlasmidRef.fasta"
	 fi
	done < <(sed -n '/CLUSTER/,/P-VALUE/p'  ${BASEDIR_OUT}${sample}"/out.txt"  | awk 'BEGIN{FS="\t"};/CLUSTER/{print $2};/.list$/{print $6}')

	MapOnPlasmid ${SAMPLE_NAME}
}


for fastq in $(ls ${FASTQ_TRIMMO_PATH}*_R1_PAIR.fastq.gz)
 do
 SAMPLE_NAME=$(echo $(basename $fastq))
 SAMPLE_NAME=$(echo $SAMPLE_NAME | cut -d '_' -f 1)
 echo ">>>>>>>>>>> Work on ${SAMPLE_NAME}"
 out=${BASEDIR_OUT}${SAMPLE_NAME}/
 mkdir $out
 cat ${FASTQ_TRIMMO_PATH}"${SAMPLE_NAME}"*".fastq.gz" > ${out}${SAMPLE_NAME}".fastq.gz"
 gunzip ${out}${SAMPLE_NAME}".fastq.gz"
 cmd="${EXEC} -i  ${out}${SAMPLE_NAME}.fastq -o ${out}out.txt -d ${DB} -b ${REF} -k 1>${out}log.txt 2>&1"
 eval ${cmd}
 rm ${out}${SAMPLE_NAME}".fastq" ${out}*"_distr" ${out}*".list"  
 
 ExtractPlamidicReads $SAMPLE_NAME
 AssembPlasmid ${SAMPLE_NAME}

done

