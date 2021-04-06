#!/usr/local/anaconda3/bin/python
import sys
import re
file_raw=sys.argv[1]
file_now=sys.argv[2]
file_peak=sys.argv[3]
pre_out=sys.argv[4]
b_file=open("./"+pre_out+"new.tsv","w")
a_file=open("./"+pre_out+"old.tsv","w")
c_file=open("./"+pre_out+"comm.tsv","w")

peak=[]
with open(file_peak,"r") as c:
	for line in c.readlines():
		line=line.strip().split()
		peak.append(tuple([line[1],line[2]]))

print(peak[:10])
def get_dic(ff):
	with open(ff,"r") as f:
		dic1={}
		for line in f.readlines():
			if re.search("m6A",line):
				ipdratio=re.search(r"IPDRatio=(.*\.\d{2});",line).group(1)
				context=re.search(r"context=(\w+);",line).group(1)
				motif=context[19:23]
				if re.search("[ACG]AT[CGT]",motif):
					flag="motif_yes"
				else:
					flag="motif_no"
				line=line.strip().split()
				p=line.index("m6A")
				peak_stat=["peak_no","null","null"]
				for i in peak:
					if int(line[p+1]) >= int(i[0]) and int(line[p+1]) <= int(i[1]):
						peak_stat=["peak_yes",i[0],i[1]]
				dic1[tuple([line[0],line[p+1]])]=[ipdratio,context,motif,flag,peak_stat]
	return dic1

dica=get_dic(file_raw)
dicb=get_dic(file_now)
a=dica.keys()
b=dicb.keys()
intersection = list(set(a).intersection(set(b)))
b_unique=list(set(b).difference(set(a)))
a_unique=list(set(a).difference(set(b)))
for i in intersection:
	print(i[0],i[1],dica[i][0],dicb[i][0],dica[i][1],dica[i][2],dica[i][3],dica[i][4][0],dica[i][4][1],dica[i][4][2],file=c_file)
for i in b_unique:
        print(i[0],i[1],dicb[i][0],dicb[i][1],dicb[i][2],dicb[i][3],dicb[i][4][0],dicb[i][4][1],dicb[i][4][2],file=b_file)
for i in a_unique:
        print(i[0],i[1],dica[i][0],dica[i][1],dica[i][2],dica[i][3],dica[i][4][0],dica[i][4][1],dica[i][4][2],file=a_file)

a_file.close()
b_file.close()
c_file.close()
