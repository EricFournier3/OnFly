from Bio import SeqIO
import os
import glob
import re

"""
Eric Fournier 2020-01-16

Extraire les regions rpoB et rrs a partir de fichier d'assemblage genbank
"""

#basedir = "/home/ericf/TEMP/TEST_EXTRACT_GENE_FROM_ASSEMBLY/"
basedir = "/data/Runs/20191016_gono-16s-cloac/cloac/ANNOTATION_PROKKA/"

outhandle = open(os.path.join(basedir,"rrs_rpoB_extraction.fasta"),'a')

gene_list = ['rpoB','16S ribosomal RNA']

gb_file_list = glob.glob(basedir + "*/*.gbk")


for gb_file in gb_file_list:
    print "Scan ", gb_file

    outdir = os.path.dirname(gb_file)

    gb_file_handle = open(gb_file)

    rec_list = SeqIO.parse(gb_file, 'genbank')

    for rec in rec_list:
        rec_id = rec.id
        for feat in rec.features:
            #rpoB
            if feat.type == 'CDS':
                try:
                    gene_qualif = feat.qualifiers['gene']

                    if re.search(gene_list[0],feat.qualifiers['gene'][0]):
                        rec.description = "rpoB"
                        SeqIO.write(rec[feat.location.start:feat.location.end],os.path.join(outdir,rec.id + "_rpoB.fasta"), "fasta")
                        SeqIO.write(rec[feat.location.start:feat.location.end],outhandle, "fasta")
                except:
                    pass

            #rrs
            if feat.type == 'rRNA':
                try:
                    gene_qualif = feat.qualifiers['product']

                    if re.search(gene_list[1],feat.qualifiers['product'][0]):
                        rec.description = "rRNA"
                        SeqIO.write(rec[feat.location.start:feat.location.end],os.path.join(outdir, rec.id + "_rrs.fasta"),"fasta")
                        SeqIO.write(rec[feat.location.start:feat.location.end], outhandle, "fasta")
                except:
                    pass


    gb_file_handle.close()


outhandle.close()

print "Finish"
