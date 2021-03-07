#source /home/yaoxinw/smrtanalysis/current/etc/setup.sh
export PATH=/home/yaoxinw/bacteria/script:$PATH:/usr/local/smrtlink/smrtcmds/bin/
Samtools=/usr/local/smrtlink/smrtcmds/bin/samtools
Blasr=/usr/local/smrtlink/smrtcmds/bin/blasr
wkd=/home/yaoxinw/bacteria/

cd ${wkd}/script
#for bac in $(cat ${wkd}/script/bac_list);
bac=$1
workd=${wkd}/process/${bac}

# prepare pure bam_file
cd $workd
blasr ${workd}/input.fofn ${wkd}/ref_assembly/${bac}/${bac}_ref/sequence/${bac}_ref.fasta -sam -out ${workd}/aligned_reads_raw.sam -sa ${wkd}/ref_assembly/${bac}/${bac}_ref/sequence/${bac}_ref.fasta.sa -regionTable ${workd}/data/filtered_regions.fofn -bestn 10 -minMatch 12 -nproc 110 -minSubreadLength 50 -minReadLength 50 -concordant -randomSeed 1 -placeRepeatsRandomly -useQuality -minPctIdentity 70.0

samFilter ${workd}/aligned_reads_raw.sam ${wkd}/ref_assembly/${bac}/${bac}_ref/sequence/${bac}_ref.fasta ${workd}/aligned_reads.sam -minPctSimilarity 70 -minAccuracy 75 -minLength 50 -seed 1 -scoreSign -1 -hitPolicy randombest
$Samtools view -b ${workd}/aligned_reads.sam -o ${workd}/aligned_reads.bam

