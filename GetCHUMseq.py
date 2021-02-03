# coding=utf-8

"""
Eric Fournier 2020-11-09

"""

import pandas as pd
import os

#base_dir = "/data/PROJETS/COVID-19_Beluga/CHUMseq/"
base_dir = os.getcwd()

target_list_file = os.path.join(base_dir,"sample_list_simon_grandjean_chum.txt")
chum_beluga_seq_file = os.path.join(base_dir,"CHUMseqOnBeluga.txt")
plate_chum_sample_list_file = os.path.join(base_dir,"CHUMseqPlateSample.txt")

# Target sample list
pd_target_list_file = pd.read_table(target_list_file)
pd_target_list_file['SAMPLE'] = pd_target_list_file['SAMPLE'].astype(str)
pd_target_list_file['SAMPLE'] = 'CHUM-' + pd_target_list_file['SAMPLE'] + 'A'
nb_records_in_pd_target_list_file = pd_target_list_file.shape[0]
print("Records in Target sample list : ", nb_records_in_pd_target_list_file)


# Beluga chum list
pd_chum_beluga_seq = pd.read_table(chum_beluga_seq_file)
pd_chum_beluga_seq['SAMPLE'] = pd_chum_beluga_seq['SAMPLE'].str.upper()
nb_records_in_pd_chum_beluga_seq = pd_chum_beluga_seq.shape[0]
print("Records in Beluga chum list : ", nb_records_in_pd_chum_beluga_seq)


# Plate sample list
pd_plate_chum_sample_list_file = pd.read_table(plate_chum_sample_list_file)
pd_plate_chum_sample_list_file['SAMPLE'] = pd_plate_chum_sample_list_file['SAMPLE'].astype(str)
#print(pd_plate_chum_sample_list_file['SAMPLE'])
nb_records_in_plate_chum_sample_list = pd_plate_chum_sample_list_file.shape[0] 
print("Records in plate sample list ", nb_records_in_plate_chum_sample_list)

#Merge

pd_merge_on_chum_beluga_seq_file = pd.merge(pd_chum_beluga_seq,pd_target_list_file,on='SAMPLE')
#print(pd_merge_on_chum_beluga_seq_file)
print("Nb merged with Beluga chum list ",pd_merge_on_chum_beluga_seq_file.shape[0])

pd_merge_on_plate_chum_sample_list_file = pd.merge(pd_plate_chum_sample_list_file,pd_target_list_file,on='SAMPLE')
#print(pd_merge_on_plate_chum_sample_list_file)
print("Nb merged with Plate sample list ", pd_merge_on_plate_chum_sample_list_file.shape[0])



















