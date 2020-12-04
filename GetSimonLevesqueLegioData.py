# coding=utf-8

"""
Eric Fournier 2020-11-05

"""

import datetime
import pandas as pd
import os
import numpy as np
import re
import sys
import logging
import gc
import argparse
import time
import glob
from Bio import SeqIO
import shutil

fastq_out = "/data/Runs/SimonLevesqueLegio/FASTQ/"
fasta_out = "/data/Runs/SimonLevesqueLegio/FASTA/"
gbk_out = "/data/Runs/SimonLevesqueLegio/GBK/"

partage_lspq_miseq_fastq_path_file = "/data/Runs/SimonLevesqueLegio/slbio_fastq_path.txt"
element_fastq_path_file = "/data/Runs/SimonLevesqueLegio/element_fastq_path.txt"
element_fasta_path_file = "/data/Runs/SimonLevesqueLegio/element_fasta_path.txt"
element_gbk_path_file = "/data/Runs/SimonLevesqueLegio/element_gbk_path.txt"

sample_list_file = "/data/Runs/SimonLevesqueLegio/Souches_sequencees_par_WGS.xlsx"
pd_sample_list_file = pd.read_excel(sample_list_file,sheet_name=0)

partage_lspq_miseq_basedir = "/mnt/Partage/LSPQ_MiSeq/"
target_samples_list = set(pd_sample_list_file['Strain'])

nb_found = 0

with open(partage_lspq_miseq_fastq_path_file) as rf:
    for fastq_path in rf:
        spec_id = os.path.basename(fastq_path).split('_')[0]
        if spec_id in target_samples_list:
            nb_found += 1
            fastq_path = fastq_path.strip('\n')
            for fastq in glob.glob(os.path.dirname(fastq_path) + "/*" + spec_id + "*.fastq.gz"):
                #print("Copy ", fastq)
                pass
                #shutil.copy2(fastq,fastq_out)
            target_samples_list.remove(spec_id)

with open(element_fastq_path_file) as rf:
    for fastq_path in rf:
        if re.search(r'Legionella_reads',fastq_path):
            spec_id = os.path.basename(fastq_path).split('_')[1]
            if not re.search(r'ID',spec_id):
                spec_id = os.path.basename(fastq_path).split('_')[0]
        else:
            spec_id = os.path.basename(fastq_path).split('_')[0]

        spec_id_corrected = re.sub(r'KID','ID',spec_id)
        if spec_id_corrected in target_samples_list:
            nb_found += 1
            fastq_path = fastq_path.strip('\n')
            for fastq in glob.glob(os.path.dirname(fastq_path) + "/*" + spec_id + "*.fastq.gz"):
                #print("Copy ",fastq)
                pass
                #shutil.copy2(fastq,fastq_out)
            target_samples_list.remove(spec_id_corrected)

print("FASTQ NOT FOUND ", target_samples_list) # {'LegioPhiladelphia_NC_002942', 'ERR426367', 'ERR426390', 'ID111737', 'ID139627'}

target_samples_list = set(pd_sample_list_file['Strain'])
nb_found = 0

with open(element_fasta_path_file) as rf:
    for fasta_path in rf:
        spec_id = os.path.basename(fasta_path).split('.')[0]
        spec_id_corrected = re.sub(r'KID','ID',spec_id)
        
        if spec_id_corrected in target_samples_list:
            nb_found += 1
            fasta_path = fasta_path.strip('\n')
            print("Copy ",fasta_path)
            shutil.copy2(fasta_path,fasta_out)
            target_samples_list.remove(spec_id_corrected)

print("FASTA NOT FOUND ", target_samples_list) # {'ID139627', 'ID111737'} 

target_samples_list = set(pd_sample_list_file['Strain'])
nb_found = 0

with open(element_gbk_path_file) as rf:
    for gbk_path in rf:
        spec_id = os.path.basename(gbk_path).split('.')[0]
        spec_id_corrected = re.sub(r'KID','ID',spec_id)
        
        if spec_id_corrected in target_samples_list:
            nb_found += 1
            gbk_path = gbk_path.strip('\n')
            print("Copy ",gbk_path)
            shutil.copy2(gbk_path,gbk_out)
            target_samples_list.remove(spec_id_corrected)

print("GBK NOT FOUND ", target_samples_list) # 
#{'ID141826', 'ID119958', 'ID120311', 'ID096215', 'ID033399', 'ID120282', 'ID120090', 'ID120094', 'ID120317', 'ID120368', 'ID144246', 'ID120169', 'ID120371', 'ID142370', 'ID120206', 'ID100127', 'ID120147', 'ID120069', 'NC_002942', 'ID126145', 'ID120086', 'ID119957', 'ID119685', 'ID108297', 'ID102959', 'ID033398', 'ID120113', 'ID127110', 'ID127279', 'ID128015', 'ID135292', 'ID119960', 'ID142978', 'ID120377', 'ID127586', 'ID120796', 'ID120344', 'ID097705', 'ID140473', 'ID120369', 'ID120315', 'ID093659', 'ID120092', 'ID120114', 'ID143073', 'ID133681', 'ID142164', 'ID103359', 'ID111737', 'ID093517', 'ID120070', 'ID120111', 'ID096203', 'ID120310', 'ID142979', 'ERR426367', 'ID142681', 'ID120328', 'ID134426', 'ID120305', 'ID033401', 'ID129566', 'ID120370', 'ID092043', 'ID120713', 'ID120071', 'ID109086', 'ID120833', 'ID092262', 'ERR426390', 'ID127792', 'ID139627'}
