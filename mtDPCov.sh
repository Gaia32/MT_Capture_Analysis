#!/bin/bash
#SBATCH --job-name=RprtDPCov
#SBATCH --output=BWA6DepthCoverageMT.out

DirRaw=(path/to/your/bam/files)

################################
### SAMTOOLS
### this script allows to extract reads mapping over the mitochondiral chromosome
### it also allows to extract the average coverage and depth of each sample in the output file BWA6DepthCoverageMT.out
### /!\ The bams need to be sorted and indexed 
source /local/env/envsamtools-1.15.sh #<-- /!\ change here the path to the samtool software / environment
################################

for file in ${DirRaw}*.bam; do
	name=${file##*/}
	id=${name%_*.bam} # <-- /!\change the * into the part of the name you don't want to keep

    samtools view $DirRaw${id}*.bam MT -o ${id}_MT.bam
    samtools coverage ${id}_MT.bam > ${id}_samcoverage.txt

	  echo "Sample_Id,"$id
	  echo -n "Coverage," ; awk 'FNR==2 {print $6}' ${id}_samcoverage.txt
	  echo -n "Depth," ; awk 'FNR==2 {print $7}' ${id}_samcoverage.txt

done

