#source /home/yaoxinw/smrtanalysis/current/etc/setup.sh
export PATH=/home/yaoxinw/bacteria/script:$PATH:/usr/local/smrtlink/smrtcmds/bin/
smrt=/home/yaoxinw/smrtanalysis
Samtools=/usr/local/smrtlink/smrtcmds/bin/samtools
Blasr=/usr/local/smrtlink/smrtcmds/bin/blasr
wkd=/home/yaoxinw/bacteria/

bac=$1
workd=${wkd}/process/${bac}
cd ${workd}
zcat modifications.gff.gz > modifications.gff

compare_result.py modifications.gff modifications_new.gff ${wkd}/medip_peak/${bac}_peaks.narrowPeak 
