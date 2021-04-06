#source /home/yaoxinw/smrtanalysis/current/etc/setup.sh
export PATH=/home/yaoxinw/bacteria/script:$PATH:/usr/local/smrtlink/smrtcmds/bin/
smrt=/home/yaoxinw/smrtanalysis
Samtools=/usr/local/smrtlink/smrtcmds/bin/samtools
Blasr=/usr/local/smrtlink/smrtcmds/bin/blasr
wkd=/home/yaoxinw/bacteria/

bac=$1
workd=${wkd}/process/${bac}
cd ${workd}
new=$(wc -l ${workd}/new.tsv | awk '{print $1}')
old=$(wc -l ${workd}/old.tsv | awk '{print $1}')
comm=$(wc -l ${workd}/comm.tsv | awk '{print $1}')
peak=$(grep -c peak_yes ${workd}/new.tsv)
echo $bac $new $old $comm $peak >> /home/yaoxinw/bacteria/all_stat


