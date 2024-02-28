#!/bin/bash
#SBATCH --job-name=testMT
#SBATCH --output=testMTconsensus.out

################################################################################
# After mapping we want to extrcat the mitochondrial reads
################################
### this script allows to extract reads mapping over the mitochondiral chromosome
### it also allows to extract the average coverage and depth of each sample
source /local/env/envsamtools-1.15.sh
################################

for file in ${DirBams}*_aln_samse_mappedQ25.sorted.bam; do
	name=${file##*/}
	id=${name%_aln_samse_*}
    samtools view $DirBams${id}_aln_samse_mappedQ25.sorted.bam MT -o ${id}_aln_samse_mappedQ25_MT.sorted.bam
    samtools coverage ${id}_aln_samse_mappedQ25_MT.sorted.bam > $DirOut${id}_samcoverage.txt
done

################################################################################
### Those commands allows to build a consensus from mitochondrial reads using angsd
### /!\ WARNING: do not put extention to the -out

source /local/env/envconda.sh
conda activate /groups/Paleogenomics/ENV/angsd

for file in ${DirBams}*sorted.bam; do 
	name=${file##*/}
  id=${name%*_sorted.bam}

  angsd -doFasta 3 -out $DirOut${id}_dF3_minDP3_minMQ30 -i ${DirBams}${id}_sorted.bam -setMinDepthInd 3 -nThreads 8 -doCounts 1 -minMapQ 30
  rm  $DirOut${id}_dF3_minDP3_minMQ30.arg
  gunzip $DirOut${id}_dF3_minDP3_minMQ30.fa.gz
  sed -i "s/>MT/>${id}_dF3_minDP3_minMQ30/g" $DirOut${id}_dF3_minDP3_minMQ30.fa # this changes the ">MT" in the name of the sample inside the file
done

############################### OPTIONS
#-setMinDepthInd 3 require at least 3 read for each individual
#-minMapQ [int] Discard bases with a mapqscore below this threshold. (mapping quality score)
#-doFasta 3 use the base with thie highest effective depth (EBD). This only works for one individual
#    where the base with the highest effective depth (the product of the mapping quality and scores)

################################################################################
# At this point we can use Mitotoolpy to find the haplogroup. Mitotoolpy runs on the computer
Mitotoolpy="C:/Users/Gaia/Desktop/Mahaut/UNIV/COURS/ENVs/MitoToolPy_Win/mitotoolpy-seq.py"

for file in ${DirFasta}*_dF3_minDP3_minMQ30.fa; do 
	name=${file##*/} 
	sample_tag=${name%_dF3_minDP3_minMQ30.fa*}
    python $Mitotoolpy -s dog -r whole -i ${DirFasta}${sample_tag}_dF3_minDP3_minMQ30.fa -o ${DirMito}${sample_tag}_MitoToolPy.txt
done
