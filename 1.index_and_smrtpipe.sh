bac=$1
wkd=/home/yaoxinw/bacteria
cd ${wkd}/process/${bac}
workd=${wkd}/process/${bac}
awk '{if($1 ~ /^>/){print $1}else{print $0}}' /home/yaoxinw/bacteria/ref_assembly/${bac}/*pb.fasta > /home/yaoxinw/bacteria/ref_assembly/${bac}/${bac}_pb.fasta
#rm -rf /home/yaoxinw/bacteria/ref_assembly/${bac}/${bac}_ref/
referenceUploader -c -p $wkd/ref_assembly/${bac} -n ${bac}_ref -f $wkd/ref_assembly/${bac}/${bac}_pb.fasta --saw 'sawriter -blt 8 -welter'
ls ${wkd}/data_h5/${bac}/*.bax.h5 > ${workd}/input.fofn
fofnToSmrtpipeInput.py ${workd}/input.fofn > ${workd}/input.xml
smrtpipe.py -D NPROC=20 --params=${workd}/prokaryotes_params_sb.xml xml:${workd}/input.xml > ${workd}/smrtpipe.log


