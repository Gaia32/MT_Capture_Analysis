#!/bin/bash
#SBATCH --job-name=RprtDPCov
#SBATCH --output=BWA6DepthCoverageMT.out

DirRaw=(/home/genouest/cnrs_umr6553/mahautgr/Mitogenomes_Analysis/BAMs/CROC1/)

################################
### SAMTOOLS
### this script allows to extract reads mapping over the mitochondiral chromosome
### it also allows to extract the average coverage and depth of each sample in the output file BWA6DepthCoverageMT.out
source /local/env/envsamtools-1.15.sh
################################

for file in ${DirRaw}*sorted.bam; do
	name=${file##*/}
	id=${name%_sorted.bam}

    #samtools view $DirRaw${id}_aln_samse_mappedQ25.sorted.bam MT -o ${id}_aln_samse_mappedQ25_MT.sorted.bam
    samtools coverage $DirRaw${id}_sorted.bam > ${id}_samcoverage.txt

	  echo "Sample_Id,"$id
	  echo -n "Coverage," ; awk 'FNR==2 {print $6}' ${id}_samcoverage.txt
	  echo -n "Depth," ; awk 'FNR==2 {print $7}' ${id}_samcoverage.txt

done

