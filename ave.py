#!/usr/local/anaconda3/bin/python
import sys
import re
import numpy as np
file1=sys.argv[1]
file2=sys.argv[2]
dic1={}
dic2={}
with open(file2,"w") as g:
	with open(file1,"r") as f:
		for line in f.readlines():
			line=line.strip().split(";")
			#print(line[3])
			if int(line[1])!=0:
				err=round(int(line[0])/int(line[1]),2)
				#print(err)
				if line[3] not in dic1.keys():
					dic1[line[3]]=[err]
					dic2[line[3]]=np.mean(dic1[line[3]])
				else:
					dic1[line[3]].append(err)
					dic2[line[3]]=round(np.mean(dic1[line[3]]),2)
	for i in dic2.keys():
		print(i,dic2[i],file=g)

