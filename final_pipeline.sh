#source /home/yaoxinw/smrtanalysis/current/etc/setup.sh
export PATH=/home/yaoxinw/bacteria/script:/usr/local/smrtlink/smrtcmds/bin/:$PATH
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

# prepare pure bam_file
cd $workd
blasr ${workd}/input.fofn ${wkd}/ref_assembly/${bac}/${bac}_ref/sequence/${bac}_ref.fasta -sam -out ${workd}/aligned_reads_raw.sam -sa ${wkd}/ref_assembly/${bac}/${bac}_ref/sequence/${bac}_ref.fasta.sa -regionTable ${workd}/data/filtered_regions.fofn -bestn 10 -minMatch 12 -nproc 110 -minSubreadLength 50 -minReadLength 50 -concordant -randomSeed 1 -placeRepeatsRandomly -useQuality -minPctIdentity 70.0
samFilter ${workd}/aligned_reads_raw.sam ${wkd}/ref_assembly/${bac}/${bac}_ref/sequence/${bac}_ref.fasta ${workd}/aligned_reads.sam -minPctSimilarity 70 -minAccuracy 75 -minLength 50 -seed 1 -scoreSign -1 -hitPolicy randombest
$Samtools view -b ${workd}/aligned_reads.sam -o ${workd}/aligned_reads.bam

# comute error_out
bam_file=${workd}/aligned_reads.bam
bam_file_ip=${workd}/all_ipd.bam
$Samtools view -f 16 -b ${bam_file_ip} > only_subreads.blasr_-_.bam
$Samtools view -F 16 -b ${bam_file_ip} > only_subreads.blasr_+_.bam
$Samtools sort only_subreads.blasr_+_.bam -o sorted_blasr1.bam
$Samtools index sorted_blasr1.bam
$Samtools sort only_subreads.blasr_-_.bam -o sorted_blasr2.bam
$Samtools index sorted_blasr2.bam

#wating smrt done
cd ${workd}/data/ 
m6a_file=${workd}/data/modifications.gff.gz
gzip -d $m6a_file

awk 'NF==9 && $7=="+" {print $0}' ${workd}/data/modifications.gff | sed 's/ /\t/g' | sed 's/coverage=//' | sed 's/;IPDRatio=/\t/' | sed 's/;context=/\t/' | sed 's/;frac=/\t/' | sed 's/;fracLow=/\t/' | sed 's/;fracUp=/\t/' | sed 's/;identificationQv=/\t/' | sed 's/\t/,/g' > ${workd}/m6a_+_smrt.csv
awk 'NF==9 && $7=="-" {print $0}' ${workd}/data/modifications.gff | sed 's/ /\t/g' | sed 's/coverage=//' | sed 's/;IPDRatio=/\t/' | sed 's/;context=/\t/' | sed 's/;frac=/\t/' | sed 's/;fracLow=/\t/' | sed 's/;fracUp=/\t/' | sed 's/;identificationQv=/\t/' | sed 's/\t/,/g' > ${workd}/m6a_-_smrt.csv

m6A_zheng_file=$workd/m6a_+_smrt.csv
m6A_fu_file=$workd/m6a_-_smrt.csv

cd ${workd}
final_A.py -r ${wkd}/ref_assembly/${bac}/${bac}_ref/sequence/${bac}_ref.fasta -s sorted_blasr1.bam -b A -a ${m6A_zheng_file} -o only_subreads_A1.tsv 1>log 2>error
final_A.py -r ${wkd}/ref_assembly/${bac}/${bac}_ref/sequence/${bac}_ref.fasta -s sorted_blasr2.bam -b A -a ${m6A_fu_file} -o only_subreads_A2.tsv 1>log 2>error

awk '{print $1,$2,$3,$6,$7}' only_subreads_A1.tsv  | sort -nk 2,2 > question_A1
awk '{print $1,$2,$3,$6,$7}' only_subreads_A2.tsv  | sort -nk 2,2 > question_A2

# compute mean error
Rscript /home/yaoxinw/bacteria/script/err_out.R question_A1 $workd
Rscript /home/yaoxinw/bacteria/script/err_out.R question_A2 $workd
