# -*- coding: utf-8 -*-

"""
Eric Fournier 2020-12-05
"""

import mysql.connector
import datetime
import pandas as pd
import os
import numpy as np
import re
import sys
import logging
import gc
import yaml 
import argparse
import glob


class CovBankDB:
    def __init__(self):
        pass
        self.yaml_conn_param = open('CovBankParam.yaml')
        self.ReadConnParam()
        self.connection = self.SetConnection()

    def CloseConnection(self):
        self.GetConnection().close()

    def SetConnection(self):
        return mysql.connector.connect(host=self.host,user=self.user,password=self.password,database=self.database)

    def GetConnection(self):
        return self.connection

        return mysql.connector.connect(host=self.host,user=self.user,password=self.password,database=self.database)

    def GetConnection(self):
        return self.connection

    def GetCursor(self):
        return self.GetConnection().cursor()

    def Commit(self):
        self.connection.commit()

    def ReadConnParam(self):
        param = yaml.load(self.yaml_conn_param,Loader=yaml.FullLoader)
        self.host = param['host']
        self.user = param['user']
        self.password = param['password']
        self.database = param['database']

base_dir = os.getcwd()

target_list_file = os.path.join(base_dir,"sample_list_simon_grandjean_chum.txt")
pd_target_list_file = pd.read_table(target_list_file)
target_list  = list(pd_target_list_file['SAMPLE'].astype(str))
#print(target_list)

covbank_obj = CovBankDB()

for target in target_list:

    #sql = "SELECT GENOME_QUEBEC_REQUETE,DATE_ENVOI_GENOME_QUEBEC from Prelevements where GENOME_QUEBEC_REQUETE like '%2015100958%'"
    sql = "SELECT GENOME_QUEBEC_REQUETE,DATE_ENVOI_GENOME_QUEBEC from Prelevements where GENOME_QUEBEC_REQUETE like '%{0}%'".format(target)

    cursor = covbank_obj.GetCursor()
    try:
        cursor.execute(sql)
        res = cursor.fetchall()
        cursor.close()
        print(res)
    except:
        print("Bug with sql ",sql)

covbank_obj.CloseConnection()
