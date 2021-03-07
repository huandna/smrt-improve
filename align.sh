#!/bin/bash
# Setting up SMRTpipe environment
echo "Setting up ENV on $(uname -n)" for task align

SEYMOUR_HOME=/home/yaoxinw/smrtanalysis/current
source $SEYMOUR_HOME/etc/setup.sh

# Create the local TMP dir if it doesn't exist
tmp_dir=$(readlink -m "/home/yaoxinw/smrtanalysis/tmpdir")
if [ ! -e "$tmp_dir" ]; then
   stat=0
   mkdir -p $tmp_dir || stat=$?
   if [[ $stat -ne 0 ]]; then
       echo "SMRTpipe Unable to create TMP dir '/home/yaoxinw/smrtanalysis/tmpdir' on $(uname -n)" 1>&2
       exit 1
   else
       echo "successfully created or found TMP dir '/home/yaoxinw/smrtanalysis/tmpdir'"
   fi
elif [[ ! -d "$tmp_dir" ]]; then
   echo "SMRTpipe TMP /home/yaoxinw/smrtanalysis/tmpdir must be a directory on $(uname -n)" 1>&2
   exit 1
fi

########### TASK metadata #############
# Task            : align
# Module          : P_Mapping
# Module Version  : 1.33.139483
# TaskType        : None
# URL             : task://Anonymous/P_Mapping/align
# createdAt       : 2020-09-06 16:30:18.584242
# createdAt (UTC) : 2020-09-06 08:30:18.584267
# ncmds           : 4
# LogPath         : /home/yaoxinw/reads1_smrt/log/P_Mapping/align.log
# Script Path     : /home/yaoxinw/reads1_smrt/workflow/P_Mapping/align.sh

# Input       : /home/yaoxinw/reads1_smrt/input.fofn
# Input       : /home/yaoxinw/reads1_smrt/data/filtered_regions.fofn
# Output      : /home/yaoxinw/reads1_smrt/data/aligned_reads.cmp.h5
#
########### END TASK metadata #############

cd /home/yaoxinw/reads1_smrt/log/P_Mapping
# Writing to log file
cat /home/yaoxinw/reads1_smrt/workflow/P_Mapping/align.sh >> /home/yaoxinw/reads1_smrt/log/P_Mapping/align.log;



echo "Running task://Anonymous/P_Mapping/align on $(uname -a)"

echo "Started on $(date -u)"
echo 'Validating existence of Input Files'
if [ -e /home/yaoxinw/reads1_smrt/input.fofn ]
then
echo 'Successfully found /home/yaoxinw/reads1_smrt/input.fofn'
else
echo 'WARNING: Unable to find necessary input file, or dir /home/yaoxinw/reads1_smrt/input.fofn.'
fi
if [ -e /home/yaoxinw/reads1_smrt/data/filtered_regions.fofn ]
then
echo 'Successfully found /home/yaoxinw/reads1_smrt/data/filtered_regions.fofn'
else
echo 'WARNING: Unable to find necessary input file, or dir /home/yaoxinw/reads1_smrt/data/filtered_regions.fofn.'
fi
echo 'Successfully validated input files'

# Task align commands:


# Completed writing Task align commands


# Task 1
pbalign "/home/yaoxinw/reads1_smrt/input.fofn" "/home/yaoxinw/ref/yizao" "/home/yaoxinw/reads1_smrt/data/aligned_reads.sam" --seed=1 --minAccuracy=0.75 --minLength=50 --concordant --algorithmOptions="-useQuality" --algorithmOptions=' -minMatch 12 -bestn 10 -minPctIdentity 70.0 -sa /home/yaoxinw/ref/yizao/sequence/yizao.fasta.sa' --hitPolicy=randombest --tmpDir=/home/yaoxinw/smrtanalysis/tmpdir --nproc=100 --regionTable=/home/yaoxinw/reads1_smrt/data/filtered_regions.fofn || exit $?
echo "Task 1 completed at $(date)"
# Task 2
echo 'Alignment Complete' || exit $?
echo "Task 2 completed at $(date)"
# Task 3
#loadChemistry.py /home/yaoxinw/reads1_smrt/input.fofn /home/yaoxinw/reads1_smrt/data/aligned_reads.cmp.h5 && loadPulses /home/yaoxinw/reads1_smrt/input.fofn /home/yaoxinw/reads1_smrt/data/aligned_reads.cmp.h5 -metrics DeletionQV,IPD,InsertionQV,PulseWidth,QualityValue,MergeQV,SubstitutionQV,DeletionTag -byread || exit $?
echo "Task 3 completed at $(date)"
# Task 4
echo 'LoadPulses Complete' || exit $?
echo "Task 4 completed at $(date)"



rcode=$?
echo "Finished on $(date -u)"
echo "Task align with nproc 100 with exit code ${rcode}."
exit ${rcode}
