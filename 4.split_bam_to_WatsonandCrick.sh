#source /home/yaoxinw/smrtanalysis/current/etc/setup.sh
export PATH=/home/yaoxinw/bacteria/script:$PATH:/usr/local/smrtlink/smrtcmds/bin/
Samtools=/usr/local/smrtlink/smrtcmds/bin/samtools
Blasr=/usr/local/smrtlink/smrtcmds/bin/blasr
wkd=/home/yaoxinw/bacteria/

cd ${wkd}/script
#for bac in $(cat ${wkd}/script/bac_list);
bac=$1
workd=${wkd}/process/${bac}

cd ${workd}
bam_file=${workd}/aligned_reads.bam
bam_file_ip=${workd}/all_ipd.bam
$Samtools view -f 16 -b ${bam_file_ip} > only_subreads.blasr_-_.bam
$Samtools view -F 16 -b ${bam_file_ip} > only_subreads.blasr_+_.bam
$Samtools sort only_subreads.blasr_+_.bam -o sorted_blasr1.bam
$Samtools index sorted_blasr1.bam
$Samtools sort only_subreads.blasr_-_.bam -o sorted_blasr2.bam
$Samtools index sorted_blasr2.bam


