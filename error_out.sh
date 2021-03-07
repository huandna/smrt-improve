export PATH=/home/yaoxinw/project/script:$PATH
Samtools=/usr/local/smrtlink/smrtcmds/bin/samtools
Blasr=/usr/local/smrtlink/smrtcmds/bin/blasr
workd=/home/yaoxinw/project
h5_file=/home/yaoxinw/data/input.fofn
m6A_zheng_file=/home/yaoxinw/project/m6a_+_smrt.csv
m6A_fu_file=/home/yaoxinw/project/m6a_-_smrt.csv
source /home/yaoxinw/smrtanalysis/current/etc/setup.sh
cutoff=0.26
prefix=$1
pstat=1006

bam_file=/home/yaoxinw/project/split_bam/aligned_reads.REF_${prefix}.bam
bam_file_ip=/home/yaoxinw/project/ip_split_bam/all.REF_${prefix}.bam
mkdir -p ${workd}/all_run/${prefix}_run
wkd=${workd}/all_run/${prefix}_run/
mkdir -p ${workd}/all_run_${pstat}/${prefix}_run
wkd2=${workd}/all_run_${pstat}/${prefix}_run
cd ${wkd2}


ln -s ${wkd}/question_A1_95 ${wkd2}/question_A1
ln -s ${wkd}/question_A2_95 ${wkd2}/question_A2

Rscript /home/yaoxinw/project/script/err_out.R ${cutoff} question_A1 $wkd2
Rscript /home/yaoxinw/project/script/err_out.R ${cutoff} question_A2 $wkd2 
