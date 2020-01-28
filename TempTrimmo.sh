#!/bin/bash
EXEC="/data/Applications/Trimmomatic/Trimmomatic-0.36/trimmomatic-0.36.jar"
FASTQ_BRUT_PATH="/data/Runs/20200115_ctrl-pulsenet/pulsenet/FASTQ_BRUT_20200123/"
FASTQ_TRIMMO_PATH="/data/Runs/20200115_ctrl-pulsenet/pulsenet/FASTQ_CLEAN_TRIMMOMATIC_20200123/"

for fastq in $(ls ${FASTQ_BRUT_PATH}*R1.fastq.gz)
                do
                        SAMPLE_NAME=$(echo $(basename $fastq))
                        SAMPLE_NAME=$(echo $SAMPLE_NAME | cut -d '_' -f 1)
                        echo -e "Trimmomatic pour ${SAMPLE_NAME}\t$(date "+%Y-%m-%d @ %H:%M$S")"

                        PAIR_R1=$fastq
                        PAIR_R2=${PAIR_R1/_R1.fastq.gz/_R2.fastq.gz}
                        PAIR_R1_TRIMMO=${PAIR_R1/_R1.fastq.gz/_R1_PAIR.fastq.gz}
                        PAIR_R1_TRIMMO=${FASTQ_TRIMMO_PATH}$(echo $(basename $PAIR_R1_TRIMMO))

                        PAIR_R2_TRIMMO=${PAIR_R1/_R1.fastq.gz/_R2_PAIR.fastq.gz}
                        PAIR_R2_TRIMMO=${FASTQ_TRIMMO_PATH}$(echo $(basename $PAIR_R2_TRIMMO))

                        UNPAIR_R1_TRIMMO=${PAIR_R1/_R1.fastq.gz/_R1_UNPAIR.fastq.gz}
                        UNPAIR_R1_TRIMMO=${FASTQ_TRIMMO_PATH}$(echo $(basename $UNPAIR_R1_TRIMMO))

                        UNPAIR_R2_TRIMMO=${PAIR_R1/_R1.fastq.gz/_R2_UNPAIR.fastq.gz}
                        UNPAIR_R2_TRIMMO=${FASTQ_TRIMMO_PATH}$(echo $(basename $UNPAIR_R2_TRIMMO))

                        LOGFILE="${FASTQ_TRIMMO_PATH}"${SAMPLE_NAME}".log"


                        TRIMMO_CMD="java -jar $EXEC PE -threads 8   -phred33 $PAIR_R1 $PAIR_R2 $PAIR_R1_TRIMMO $UNPAIR_R1_TRIMMO $PAIR_R2_TRIMMO $UNPAIR_R2_TRIMMO LEADING:20 TRAILING:20 SLIDINGWINDOW:4:20 MINLEN:50 "
			#echo "CMD IS " ${TRIMMO_CMD}
                        eval $TRIMMO_CMD
        done
