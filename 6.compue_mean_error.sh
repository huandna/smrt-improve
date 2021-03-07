#source /home/yaoxinw/smrtanalysis/current/etc/setup.sh
export PATH=/home/yaoxinw/bacteria/script:$PATH:/usr/local/smrtlink/smrtcmds/bin/
Samtools=/usr/local/smrtlink/smrtcmds/bin/samtools
Blasr=/usr/local/smrtlink/smrtcmds/bin/blasr
wkd=/home/yaoxinw/bacteria/

cd ${wkd}/script
#for bac in $(cat ${wkd}/script/bac_list);
bac=$1
workd=${wkd}/process/${bac}


# compute mean error
cd ${workd}
Rscript /home/yaoxinw/bacteria/script/err_out.R question_A1 $workd
Rscript /home/yaoxinw/bacteria/script/err_out.R question_A2 $workd
