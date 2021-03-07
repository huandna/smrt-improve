#source /home/yaoxinw/smrtanalysis/current/etc/setup.sh
export PATH=/home/yaoxinw/bacteria/script:$PATH:/usr/local/smrtlink/smrtcmds/bin/
Samtools=/usr/local/smrtlink/smrtcmds/bin/samtools
Blasr=/usr/local/smrtlink/smrtcmds/bin/blasr
wkd=/home/yaoxinw/bacteria/

cd ${wkd}/script
#for bac in $(cat ${wkd}/script/bac_list);
bac=$1
workd=${wkd}/process/${bac}


bam_file=${workd}/aligned_reads.bam
bam_file_ip=${workd}/all_ipd.bam

cd ${workd} 
m6a_file=${workd}/data/modifications.gff.gz

zcat $m6a_file | awk 'NF==9 && $7=="+" {print $0}' - | sed 's/ /\t/g' | sed 's/coverage=//' | sed 's/;IPDRatio=/\t/' | sed 's/;context=/\t/' | sed 's/;frac=/\t/' | sed 's/;fracLow=/\t/' | sed 's/;fracUp=/\t/' | sed 's/;identificationQv=/\t/' | sed 's/\t/,/g' > ${workd}/m6a_+_smrt.csv
zcat $m6a_file | awk 'NF==9 && $7=="-" {print $0}' - | sed 's/ /\t/g' | sed 's/coverage=//' | sed 's/;IPDRatio=/\t/' | sed 's/;context=/\t/' | sed 's/;frac=/\t/' | sed 's/;fracLow=/\t/' | sed 's/;fracUp=/\t/' | sed 's/;identificationQv=/\t/' | sed 's/\t/,/g' > ${workd}/m6a_-_smrt.csv

m6A_zheng_file=${workd}/m6a_+_smrt.csv
m6A_fu_file=${workd}/m6a_-_smrt.csv

cd ${workd}
final_A.py -r ${wkd}/ref_assembly/${bac}/${bac}_ref/sequence/${bac}_ref.fasta -s sorted_blasr1.bam -b A -a ${m6A_zheng_file} -o only_subreads_A1.tsv > final_A_LOG1
final_A.py -r ${wkd}/ref_assembly/${bac}/${bac}_ref/sequence/${bac}_ref.fasta -s sorted_blasr2.bam -b A -a ${m6A_fu_file} -o only_subreads_A2.tsv > final_A_LOG2

awk '{print $1,$2,$3,$6,$7}' only_subreads_A1.tsv  | sort -nk 2,2 > question_A1
awk '{print $1,$2,$3,$6,$7}' only_subreads_A2.tsv  | sort -nk 2,2 > question_A2

