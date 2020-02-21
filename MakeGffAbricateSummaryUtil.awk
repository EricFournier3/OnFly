BEGIN {FS="\t"}
NR>1{
	{if(length($15) > 2){
                if(index($15,";")){
		         split($15,antibio_name_arr,";")
                         
			}
		else{
                        split($15,antibio_name_arr,"/")
		    }
		
		antibio_name=antibio_name_arr[length(antibio_name_arr)]
		}
	 else{
             antibio_name="NA"
	     }	
	}
        ;
	{
	#print $12" -- "$15" -- "antibio_name
	print $2"\t"$12"\tgene\t"$3"\t"$4"\t"$11"\t"$5"\t1\tID="$13"-"NR";Name="$6";cov="$10";antibio="antibio_name
	}

}
