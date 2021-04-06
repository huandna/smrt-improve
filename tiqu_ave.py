#!/usr/local/anaconda3/bin/python
import sys
import re
import numpy as np
file1=sys.argv[1]
cut=float(sys.argv[2])
dic1={}
dic2={}
with open("./err_reads_"+str(cut)+".txt","w") as g:
	with open(file1,"r") as f:
		for line in f.readlines():
			line=line.strip().split()
			if float(line[1]) >= cut:
				print(line[0],file=g)

