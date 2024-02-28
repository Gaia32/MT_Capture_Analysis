#!/bin/bash
#SBATCH --job-name=statsMT

###################################################################
# This script allows to get statistics from the bams used to	  #
# create the mt tree.
####################################################################

source /local/env/envsamtools-1.15.sh

rm res.txt	

for file in /groups/Paleogenomics/DOG/Capture_nucleaire/annee1-CROC_CAPTURE_JAN2021/MO_results_capture_good_2/*_sort_fixmate_sorted.bam ; do
  	name=${file##*/}
	sample_tag=${name%_sort_fixmate_sorted.bam} # deja filtr� sur la qual
	echo "Sample "$sample_tag >> res.txt

	source /local/env/envsamtools-1.15.sh
	samtools stats $file  | grep "average length" >> res.txt		
	samtools stats $file  | grep "SN	raw total sequences:" >> res.txt	
	samtools stats $file  | grep "SN	reads mapped:" >> res.txt	
	samtools stats $file  | grep "average quality" >> res.txt
	samtools depth  $file  |  awk '{sum+=$3} END { print "Average = ",sum/NR}' >> res.txt
	samtools stats $file  | grep ^COV | cut -f 2- >> res.txt

	#mapped reads MT
	awk 'FNR==1 {print $1}' ${sample_tag}_flagstat_mappedQ25_MT.sorted.txt >> res.txt
	#Average coverage total
	cat {sample_tag}_samcoverage_mappedQ25.txt | awk '{sum+=$6} END { print "Average = ",sum/NR}' >> res.txt
	#Average depth total
	cat ${sample_tag}_samcoverage_mappedQ25.txt | awk '{sum+=$7} END { print "Average = ",sum/NR}' >> res.txt

done