#source /home/yaoxinw/smrtanalysis/current/etc/setup.sh
export PATH=/home/yaoxinw/bacteria/script:$PATH:/usr/local/smrtlink/smrtcmds/bin/
smrt=/home/yaoxinw/smrtanalysis
Samtools=/usr/local/smrtlink/smrtcmds/bin/samtools
Blasr=/usr/local/smrtlink/smrtcmds/bin/blasr
wkd=/home/yaoxinw/bacteria/

bac=$1
workd=${wkd}/process/${bac}
h5_file=${workd}/input.fofn
newsam=${workd}/new.sam
cut_off=0.4
cd ${workd}

$Samtools view -h aligned_reads.bam > aligned_reads.sam
grep -vf ${workd}/err_reads_${cut_off}.txt  ${workd}/aligned_reads.sam > ${workd}/new.sam

samtoh5 ${newsam} ${wkd}/ref_assembly/${bac}/${bac}_ref/sequence/${bac}_ref.fasta $workd/aligned_reads_new.h5 -readType standard

loadChemistry.py $h5_file $workd/aligned_reads_new.h5 && loadPulses $h5_file $workd/aligned_reads_new.h5 -metrics DeletionQV,IPD,InsertionQV,PulseWidth,QualityValue,MergeQV,SubstitutionQV,DeletionTag -byread || exit $?

ipdSummary.py -v -W ${workd}/data/base_mod_contig_ids.txt  --methylFraction    --identify m6A,m4C   --mapQvThreshold 240  --paramsPath ${smrt}/current/analysis/etc/algorithm_parameters/2014-09/kineticsTools  --numWorkers 100 --summary_h5 ${workd}/temp_kinetics.h5 \
--gff ${workd}/modifications_new.gff \
--csv ${workd}/modifications_new.csv \
--reference ${wkd}/ref_assembly/${bac}/${bac}_ref/sequence/${bac}_ref.fasta \
$workd/aligned_reads_new.h5 || exit $?
rm aligned_reads.sam

