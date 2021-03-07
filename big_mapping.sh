export PATH=/home/yaoxinw/project/script:$PATH
Samtools=/usr/local/smrtlink/smrtcmds/bin/samtools
Blasr=/usr/local/smrtlink/smrtcmds/bin/blasr
workd=/home/yaoxinw/project
h5_file=/home/yaoxinw/data/input.fofn
#awk 'NF==9 && $7=="+" {print $0}' ./naive_modifications.gff | sed 's/ /\t/g' | sed 's/coverage=//' | sed 's/;IPDRatio=/\t/' | sed 's/;context=/\t/' | sed 's/;frac=/\t/' | sed 's/;fracLow=/\t/' | sed 's/;fracUp=/\t/' | sed 's/;identificationQv=/\t/' | sed 's/\t/,/g' > m6a_+_smrt.csv
m6A_zheng_file=/home/yaoxinw/project/m6a_+_smrt.csv
m6A_fu_file=/home/yaoxinw/project/m6a_-_smrt.csv
source /home/yaoxinw/smrtanalysis/current/etc/setup.sh
cutoff=0.26
prefix=$1
#blasr /home/yaoxinw/all_smrt/input.fofn /home/yaoxinw/ref/yizao/sequence/yizao.fasta -sam -out ${workd}/aligned_reads_raw.sam -sa /home/yaoxinw/ref/yizao/sequence/yizao.fasta.sa -regionTable /home/yaoxinw/all_smrt/data/filtered_regions.fofn -bestn 10 -minMatch 12 -nproc 110 -minSubreadLength 50 -minReadLength 50 -concordant -randomSeed 1 -placeRepeatsRandomly -useQuality -minPctIdentity 70.0
#samFilter ${workd}/aligned_reads_raw.sam /home/yaoxinw/ref/yizao/sequence/yizao.fasta ${workd}/aligned_reads.sam -minPctSimilarity 70 -minAccuracy 75 -minLength 50 -seed 1 -scoreSign -1 -hitPolicy randombest
#$Samtools view -b ${workd}/aligned_reads.sam -o ${workd}/aligned_reads.bam
#bamtools split -in ${workd}/aligned_reads.bam -reference 
#mv aligned_reads.REF* ${workd}/split_bam/

#cd /home/yaoxinw/data/
#for i in $(cat /home/yaoxinw/data/new);
#do 
#pre_m=${i};
#/usr/local/smrtlink/smrtcmds/bin/bax2bam ${pre_m}.*.h5 -o ${pre_m};
#$Blasr ${pre_m}.subreads.bam /home/yaoxinw/ref/yizao/sequence/yizao.fasta --out ${pre_m}.blasr.bam --bam --bestn 10 --minMatch 12 --nproc 110 --minSubreadLength 50 --minReadLength 50 --concordant --randomSeed 1 --placeRepeatsRandomly --useQuality --minPctIdentity 70.0;
#done

#ls /home/yaoxinw/data/*blasr.bam > /home/yaoxinw/data/bam_list
#bamtools merge -list /home/yaoxinw/data/bam_list -out $workd/all.bam 
#bamtools split -in $workd/all.bam -reference  
#mkdir -p ${workd}/ip_split_bam
#mv ${workd}/*REF*.bam ${workd}/ip_split_bam
bam_file=/home/yaoxinw/project/split_bam/aligned_reads.REF_${prefix}.bam
bam_file_ip=/home/yaoxinw/project/ip_split_bam/all.REF_${prefix}.bam
mkdir -p ${workd}/all_run/${prefix}_run
wkd=${workd}/all_run/${prefix}_run/
cd $wkd

$Samtools view -f 16 -b ${bam_file_ip} > only_subreads.blasr_-_.bam
$Samtools view -F 16 -b ${bam_file_ip} > only_subreads.blasr_+_.bam
$Samtools sort only_subreads.blasr_+_.bam -o sorted_blasr1.bam
$Samtools index sorted_blasr1.bam
$Samtools sort only_subreads.blasr_-_.bam -o sorted_blasr2.bam
$Samtools index sorted_blasr2.bam
/home/yaoxinw/project/script/final_A.py -s sorted_blasr1.bam -b A -a ${m6A_zheng_file} -o only_subreads_A1.tsv 1>log 2>error 
/home/yaoxinw/project/script/final_A.py -s sorted_blasr2.bam -b A -a ${m6A_fu_file} -o only_subreads_A2.tsv 1>log 2>error
awk '{print $1,$2,$3,$6,$7}' ./only_subreads_A1.tsv  | sort -nk 2,2 > question_A1
awk '{print $1,$2,$3,$6,$7}' ./only_subreads_A2.tsv  | sort -nk 2,2 > question_A2
Rscript /home/yaoxinw/project/script/2020824.R ${cutoff} question_A1 $wkd
Rscript /home/yaoxinw/project/script/2020824.R ${cutoff} question_A2 $wkd 


$Samtools sort $bam_file -o sorted_file.bam 
$Samtools view -h sorted_file.bam > aligned_reads.sam
grep -vf question_A1_${cutoff}.txt $wkd/aligned_reads.sam | grep -vf question_A2_${cutoff}.txt - > $wkd/aligned_reads_${cutoff}.sam
samtoh5 $wkd/aligned_reads_${cutoff}.sam /home/yaoxinw/ref/yizao/sequence/yizao.fasta $wkd/aligned_reads_${cutoff}.h5 -readType standard
loadChemistry.py $h5_file $wkd/aligned_reads_${cutoff}.h5 && loadPulses $h5_file $wkd/aligned_reads_${cutoff}.h5 -metrics DeletionQV,IPD,InsertionQV,PulseWidth,QualityValue,MergeQV,SubstitutionQV,DeletionTag -byread || exit $?
ipdSummary.py -v -W /home/yaoxinw/all_smrt/data/base_mod_contig_ids.txt  --methylFraction    --identify m6A,m4C   --mapQvThreshold 240  --paramsPath /home/yaoxinw/smrtanalysis/current/analysis/etc/algorithm_parameters/2014-09/kineticsTools  --numWorkers 100 --summary_h5 ${workd}/temp_kinetics.h5 \
--gff ${wkd}/modifications_${cutoff}.gff \
--csv ${wkd}/modifications_${cutoff}.csv \
--reference /home/yaoxinw/ref/yizao/sequence/yizao.fasta \
$wkd/aligned_reads_${cutoff}.h5 || exit $?
