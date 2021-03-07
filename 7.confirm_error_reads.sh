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
sed -i -n '2,$p' ${workd}/question_A2__error.csv
sed -i -n '2,$p' ${workd}/question_A1__error.csv
cat ${workd}/question_A2__error.csv ${workd}/question_A1__error.csv > ${workd}/all_error.csv 
ave.py ${workd}/all_error.csv ${workd}/all_err.out
rm ${workd}/all_error.csv

for i in 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9;
do
tiqu_ave.py ${workd}/all_err.out $i
if [ -s ${workd}/err_reads_${i}.txt ];
then
echo "you"
else
echo "meiyou"
echo "meiyou" > ${workd}/err_reads_${i}.txt
fi
done

