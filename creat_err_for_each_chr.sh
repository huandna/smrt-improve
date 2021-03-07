export PATH=/home/yaoxinw/project/script:$PATH
Samtools=/usr/local/smrtlink/smrtcmds/bin/samtools
Blasr=/usr/local/smrtlink/smrtcmds/bin/blasr
workd=/home/yaoxinw/project
h5_file=/home/yaoxinw/data/input.fofn
m6A_zheng_file=/home/yaoxinw/project/m6a_+_smrt.csv
m6A_fu_file=/home/yaoxinw/project/m6a_-_smrt.csv
source /home/yaoxinw/smrtanalysis/current/etc/setup.sh
prefix=$1
pstat=1006

bam_file=/home/yaoxinw/project/split_bam/aligned_reads.REF_${prefix}.bam
bam_file_ip=/home/yaoxinw/project/ip_split_bam/all.REF_${prefix}.bam
mkdir -p ${workd}/all_run/${prefix}_run
wkd=${workd}/all_run/${prefix}_run/
mkdir -p ${workd}/all_run_${pstat}/${prefix}_run
wkd2=${workd}/all_run_${pstat}/${prefix}_run
cd ${wkd2}

awk -F ";" '{print $4}' ${wkd2}/question_A2_0.26_error.csv | sed -n '2,$p' > ${wkd2}/reads2
awk -F ";" '{print $4}' ${wkd2}/question_A1_0.26_error.csv | sed -n '2,$p' > ${wkd2}/reads1
cat ${wkd2}/reads1 ${wkd2}/reads2 | sort -u > ${wkd2}/read_now
LC_ALL=C grep -F -f ${wkd2}/read_now /home/yaoxinw/project/scale_run/sorted.all_err.out > ${wkd2}/read_now_err
rm ${wkd2}/reads2
rm ${wkd2}/reads1
for i in 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9;
do

/home/yaoxinw/project/scale_run/script/tiqu_ave.py ${wkd2}/read_now_err $i

if [ -s ${wkd2}/err_reads_${i}.txt ];
then
echo "you"
else
echo "meiyou"
echo "meiyou" > ${wkd2}/err_reads_${i}.txt
fi

done





