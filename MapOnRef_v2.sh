#!/bin/bash


IDENTITY_THRESHOLD=0.95
MIN_BEDTOOLS_COV=10
C_NEG="Pseudomonas_fluorescens_ASM23706v1"

base_dir="/data/Users/Eric/NGSjenkins/20191016_gono-16s-cloac/16s/METAGENOMIC_MAP/"
spec_list=(L164263-16S L165112-16S L165803-16S L166501-16S)
ref_dir="/home/foueri01@inspq.qc.ca/ProjetsNGS/MAP_REF/"
#         0        1                                   2                               3                                      4                                       5                              6                             7                                 8                                9                                     10                             11       
ref_list=(${C_NEG} Enterobacter_bugandensis_CP039453.1 Neisseria_gonorrhoeae_ASM2010v1 Streptococcus_parasanguinis_ASM16467v2 Fusobacterium_periodonticum_ASM276373v1 Ochrobactrum_anthropi_ASM74295 Rothia_mucilaginosa_ASM1102v1 Streptococcus_pneumoniae_ASM688v1 Klebsiella_pneumoniae_ASM22048v1 Prevotella_melaninogenica_ASM360977v1 Streptococcus_mitis_ASM14858v3 Veillonella_parvula_ASM2494v1)


GetRef(){
	if [ "$1" = "L164263-16S" ]
		then
		target_ref=(${ref_list[4]}) # Fusobacterium_periodonticum_ASM276373v1
#		target_ref=(${ref_list[0]} ${ref_list[10]} ${ref_list[7]} ${ref_list[2]}) #  C_NEG   Streptococcus_mitis_ASM14858v3  Streptococcus_pneumoniae_ASM688v1 Neisseria_gonorrhoeae_ASM2010v1
	elif [ "$1" = "L165112-16S" ]
		then
		target_ref=(${ref_list[4]}) # Fusobacterium_periodonticum_ASM276373v1
#		target_ref=(${ref_list[0]} ${ref_list[9]} ${ref_list[11]} ${ref_list[2]}) # C_NEG Prevotella_melaninogenica_ASM360977v1  Veillonella_parvula_ASM2494v1  Neisseria_gonorrhoeae_ASM2010v1
	elif [ "$1" = "L165803-16S" ]
		then
		target_ref=(${ref_list[4]} ${ref_list[3]} ${ref_list[6]}) # Fusobacterium_periodonticum_ASM276373v1 Streptococcus_parasanguinis_ASM16467v2 Rothia_mucilaginosa_ASM1102v1
#		target_ref=(${ref_list[0]} ${ref_list[8]} ${ref_list[2]}) # C_NEG  Klebsiella_pneumoniae_ASM22048v1 Neisseria_gonorrhoeae_ASM2010v1
	elif [ "$1" = "L166501-16S" ]
		then
		target_ref=(${ref_list[4]}) # Fusobacterium_periodonticum_ASM276373v1
		#target_ref=(${ref_list[0]} ${ref_list[6]} ${ref_list[3]} ${ref_list[2]}) # C_NEG Rothia_mucilaginosa_ASM1102v1 Streptococcus_parasanguinis_ASM16467v2 Neisseria_gonorrhoeae_ASM2010v1
	fi

}


for ref in ${ref_list[@]}
	do
	cmd_index="smalt index -k 20 -s 4 ${ref_dir}${ref} ${ref_dir}${ref}.fasta > /dev/null"
	#echo ${cmd_index} 
	eval ${cmd_index}
done


for spec in ${spec_list[@]}
	do
	echo "*********************  Handle ${spec} ***************************"
	GetRef $spec


	prefix_spec=${base_dir}${spec}

	for myref in ${target_ref[@]}
		do
		echo -e "\tMap on ${myref}"

		prefix_ref=${ref_dir}${myref}
		prefix_map=${base_dir}${spec}_ON_${myref}

		cmd_map="smalt map -f sam -l pe -y ${IDENTITY_THRESHOLD} -i 500 -o ${prefix_map}.sam ${prefix_ref} ${prefix_spec}_R1.fastq.gz ${prefix_spec}_R2.fastq.gz"
		#echo $cmd_map
		eval $cmd_map
		
		cmd_convert_to_bam="samtools view -bS ${prefix_map}.sam > ${prefix_map}.bam ; rm ${prefix_map}.sam"
		#echo $cmd_convert_to_bam
		eval $cmd_convert_to_bam
		
		cmd_bam_sort="samtools sort ${prefix_map}.bam ${prefix_map}_sort"
		#echo $cmd_bam_sort
		eval $cmd_bam_sort

		cmd_bam_index="samtools index ${prefix_map}_sort.bam"
		#echo $cmd_bam_index
		eval $cmd_bam_index

		MAPPED_READS=$(samtools view -c -F 260 ${prefix_map}.bam)
		TOTAL_READS=$(expr ${MAPPED_READS} + $(samtools view -c -f 4 ${prefix_map}.bam))
		PERCENT_MAP=$(echo "scale=4;(${MAPPED_READS}/${TOTAL_READS})*100" | bc -l)
		
		cmd_bedtools="bedtools genomecov -ibam ${prefix_map}_sort.bam -bg | awk '\$4 > ${MIN_BEDTOOLS_COV}' | sort -n -k 4 > ${prefix_map}_bedgraph_sort_by_cov.txt; sort -n -k 3 ${prefix_map}_bedgraph_sort_by_cov.txt > ${prefix_map}_bedgraph_sort_by_position.txt "
	#	echo ${cmd_bedtools}                

		eval $cmd_bedtools
		echo -e "Identity threshold:\t${IDENTITY_THRESHOLD}\n" > ${prefix_map}_MAP_STAT.txt
		echo -e "Mapped:\t${MAPPED_READS}\nTotal:\t${TOTAL_READS}\nPercent:\t${PERCENT_MAP}" >> ${prefix_map}_MAP_STAT.txt

	done

done

echo "Terminé"
