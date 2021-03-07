#source /home/yaoxinw/smrtanalysis/current/etc/setup.sh
export PATH=/home/yaoxinw/bacteria/script:$PATH:/usr/local/smrtlink/smrtcmds/bin/
Samtools=/usr/local/smrtlink/smrtcmds/bin/samtools
Blasr=/usr/local/smrtlink/smrtcmds/bin/blasr
wkd=/home/yaoxinw/bacteria/

cd ${wkd}/script
#for bac in $(cat ${wkd}/script/bac_list);
bac=$1
workd=${wkd}/process/${bac}

cd ${wkd}/data_h5/${bac}
# prepare h5tobam  and align
for i in $(ls);do echo ${i%%.*} >> ./movie_list;done
sort -u movie_list > movie_list2 && mv movie_list2 movie_list
for pre_m in $(cat movie_list);
do
bax2bam ./${pre_m}.*.h5 -o ${pre_m};
$Blasr ${pre_m}.subreads.bam ${wkd}/ref_assembly/${bac}/${bac}_ref/sequence/${bac}_ref.fasta --out ${wkd}/data_h5/${bac}/${pre_m}.blasr.bam --bam --bestn 10 --minMatch 12 --nproc 110 --minSubreadLength 50 --minReadLength 50 --concordant --randomSeed 1 --placeRepeatsRandomly --useQuality --minPctIdentity 70.0;
done

if [[ $(ls ./*.subreads.bam | wc -l) = 1 ]];then 
	mv ${wkd}/data_h5/${bac}/*.blasr.bam ${workd}/all_ipd.bam
else 
	ls ${wkd}/data_h5/${bac}/*blasr.bam > ${wkd}/data_h5/${bac}/bam_list
	bamtools merge -list ${wkd}/data_h5/${bac}/bam_list -out ${workd}/all_ipd.bam
fi

