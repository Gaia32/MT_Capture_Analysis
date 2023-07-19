#!/bin/bash
#SBATCH --job-name=MTconsensus
#SBATCH --output=buildMTconsensus.out

DirRaw=(path/to/your/bam/files/)
DirOut=(path/to/your/output/consensus/)

#################################
### ANGSD  
### /!\ don't forget to not put extensions at the end of the -out prefix
### this script allows to build a consensus from mitochondrial reads 
source /local/env/envconda.sh
conda activate /groups/Paleogenomics/ENV/angsd #<-- /!\ change here the path to the samtool software / environment
#################################

for file in ${DirRaw}*.bam; do 
	name=${file##*/}
	id=${name%_*bam} # <-- /!\change the * into the part of the name you don't want to keep

        angsd -doFasta 3 -out $DirOut${id}_dF3_minDP3_minMQ30 -i ${DirRaw}${id}_aln_samse_mappedQ25_MT.sorted.bam \
        -setMinDepthInd 3 \
        -nThreads 8 \
        -doCounts 1 \
        -minMapQ 30
        
        rm  $DirOut${id}_dF3_minDP3_minMQ30.arg  # <-- /!\ remove this line if you want to keep the argument file
        gunzip $DirOut${id}_dF3_minDP3_minMQ30.fa.gz
        sed -i "s/>MT/>${id}_dF3_minDP3_minMQ30/g" $DirOut${id}_dF3_minDP3_minMQ30.fa # <-- this changes the ">MT" in the name of the sample inside the file into the wanted name
done


################################# OPTIONS
#-setMinDepthInd 3 require at least 3 read for each individual
#-minMapQ [int]
# Discard bases with a mapqscore below this threshold. (mapping quality score)
#-doFasta 3
#    use the base with thie highest effective depth (EBD). This only works for one individual
# where the base with the highest effective depth (the product of the mapping quality and scores)