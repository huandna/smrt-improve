#!/usr/local/anaconda3/bin/python
import argparse
import os
import pysam
parser = argparse.ArgumentParser( description='Put a description of your script here')
parser.add_argument('-s', '--sam_file', type=str, required=True, help='Path to an input file to be read' )
parser.add_argument('-a', '--m6a_file', type=str, required=True, help='Path to an input file to be read' )
parser.add_argument('-o', '--out_file', type=str, required=False, help='Path to an input file to be read' )
parser.add_argument('-b', '--base', type=str, required=False, help='Path to an input file to be read' )
parser.add_argument('-r', '--ref_seq', type=str, required=True, help='Path to an input file to be read' )
args = parser.parse_args()
if args.base:
	base=args.base
else:
	base="A"
if args.out_file:
	g=open(args.out_file,"w")
else:
	g=open(str(args.sam_file).split(".")[0]+"_" +str(base) + ".tsv","w")
samfile = pysam.AlignmentFile(args.sam_file, "rb")
seq=pysam.FastaFile(args.ref_seq)
m6a_dic={}
with open(args.m6a_file,"r") as a:
	for line in a.readlines():
		line=line.strip().split(",")
		m6a_dic[tuple([line[0],line[3]])]=[line[2],line[8],line[9],line[10]]
#  there is only "=" and no "m" in this bam version 
#  7 represent "=" in cigar
while True:
	try:
		reads1 = next(samfile)
		real_m=sum([i[1] for i in reads1.cigartuples if i[0]==7])
		x=sum([i[1] for i in reads1.cigartuples if i[0]==8])
		d=sum([i[1] for i in reads1.cigartuples if i[0]==1])
		i=sum([i[1] for i in reads1.cigartuples if i[0]==2])
		identiy=real_m/(real_m+d+i+x)
		pair=reads1.cigartuples
		if identiy >= 0.75 and reads1.query_alignment_length >=50:
		#if True:
			pre_pos_pair=reads1.get_aligned_pairs(matches_only=True)
			pos_pair=[j for j in pre_pos_pair if reads1.seq[j[0]]==base]
			reads_pos=[int(i[0]) for i in pos_pair]
			ref_pos=[i[1]+1 for i in pos_pair]
			ip=[reads1.get_tag( 'ip')[j] for j in reads_pos]
			pw=[reads1.get_tag( 'pw')[j] for j in reads_pos]
			for i in range(len(pos_pair)):
				if reads_pos[i]-20>=0 and reads_pos[i]+21<=len(reads1.seq):
					reads_contex=reads1.seq[reads_pos[i]-20:reads_pos[i]+21]
					reads_contex_ipd="-".join([str(i) for i in reads1.get_tag( 'ip')[reads_pos[i]-20:reads_pos[i]+21]])
				else:
					reads_contex="NONE"
					reads_contex_ipd="NONE"
				if seq.fetch(reference=reads1.reference_name, start=ref_pos[i]-1, end=ref_pos[i]) != base:
					print(tuple([reads1.reference_name,str(ref_pos[i])]))
					continue
				elif tuple([reads1.reference_name,str(ref_pos[i])]) in m6a_dic.keys():
					message=m6a_dic[tuple([reads1.reference_name,str(ref_pos[i])])]
				elif ref_pos[i]-21 >= 0 and ref_pos[i]+20 <= reads1.header.get_reference_length(reads1.reference_name) :
					context=seq.fetch(reference=reads1.reference_name, start=ref_pos[i]-21, end=ref_pos[i]+20)
					message=tuple(["N","N",context,"N"])
				else:
					message=tuple(["N","N","N","N"])
				print(reads1.reference_name,ref_pos[i],reads1.qname,reads1.query_length,reads_pos[i]+1,ip[i],pw[i],message[0],message[1],message[2],message[3],reads_contex,reads_contex_ipd,file=g)
	except StopIteration:
		break
g.close()
samfile.close()

