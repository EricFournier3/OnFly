#!/bin/bash

dragen_dir="/data/Runs/20210112_RVOP2/rvop2/Dragen/"

appresult_out=${dragen_dir}"appresult.txt"
list_cmd="bs list appresult --project-name=20210112_RVOP2 --stdout=${appresult_out} --format=csv"

eval ${list_cmd}

OLDIFS=$IFS
IFS=","

while read Id spec session
    do
    if ! [[ ${session} =~ "AppSession.Name" ]];
        then
        #echo "Id ${Id} spec ${spec} session ${session}"
        spec=$(echo ${spec} | cut -d '_' -f1)
        echo ">>>>>> Download Dragen resuls for ${spec}"

        download_cmd="bs download appresult -i ${Id} -o ${dragen_dir}${spec}"
        #echo ${download_cmd}
        eval ${download_cmd}

    fi
done < ${appresult_out}

IFS=${OLDIFS}
