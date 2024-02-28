#!/bin/bash
#SBATCH --job-name=faToTree
#SBATCH --output=fasta2Tree.out
#SBATCH --mem=80G 
#SBATCH --cpus-per-task=20

#########################################################################################
# Those are the different commmand used to create the phylogenetic tree from the individuals 
# fastas.
#   You can change the "#SBATCH --mem=80G & #SBATCH --cpus-per-task=20" according to where 
# you are in the pipeline (you may not need 80G).
#########################################################################################
#########################################################################################

dir="/groups/Paleogenomics/DOG/Captures/MITO/2_consensus_fasta/Fastas/" # on prend les fasta individuels
dirout="/groups/Paleogenomics/DOG/Captures/MITO/3_multiFastas/CROCWOOF/" # on créer les multifasta par projet

for suffix in "CROC1" "CROC2" "CROC3" "WOOF" ; do # on itere sur les suffixes
    if [ -f $dirout${suffix}_multiFasta.fa ] ; then # si le fichier multifasta existe on le supprime
        rm $dirout${suffix}_multiFasta.fa  
    fi
    touch $dirout${suffix}_multiFasta.fa # on créer le fichier multifasta
    for file in $dir${suffix}/* ; do
        cat $file >> $dirout${suffix}_multiFasta.fa # on ajoute chacun des contenus des fasta                                          
    done                                           # à la fin du fichier de multifasta
done

#### then we combine CROC 1 2 3 together into one single file (233 samples)
for file in ./CROC* ; do cat $file >> 233ALLCROC_multiFasta.fa ; done

#######################################################
# now we need to filter out samples with coverage <90%
# no need to do it for woof samples, they are already >90%.
#
# We use the script handleMultiFasta.py to get the samples we want
# /!\ carreful, the script needs to be run on the personnal computer 
# as Biopython is not on the server
python handleMultiFasta.py # we use the "getSpecificSamples" funtion 
#            PS: we can also use trimal to remove spurious sequences

#######################################################
# Next we concatenate all multifastas together :
#     * /AncientModernPublished/11bergstrom2022.fasta 
#     * /AncientModernPublished/157ancient79ModernPublished.fa
#     * /eDOGSeWOLVES/aligned_76eDogs_eWolves.fasta
#     * /SUP90%_samples/142CROCsup90_multiFasta.fa
#     * /CROCWOOF/WOOF_multiFasta.fa
# /!\ we need to check each time we add a multifasta to the total multialigment if the sequences are well aligned, if not, we need to use mafft online (https://mafft.cbrc.jp/alignment/server/index.html) 
    # to align all sequences together
    # RESULT: aligned480sequences.fasta

#######################################################
# Now we just replace the N's with "-"  using a simple Ctrl+H

#######################################################
# # Now we will use the function "changeSeqIDs" from the script "handleMultiFasta.py"
# python handleMultiFasta.py 

#######################################################
# next we want to trim the sites where we don't have a lot of informlation: e.g. sites with a lot of gaps
source /local/env/envconda.sh
conda activate /groups/Paleogenomics/ENV/trimal 

 trimal -in /groups/Paleogenomics/DOG/Captures/MITO/3_multiFastas/newID_aligned480sequences.fasta \
 -out /groups/Paleogenomics/DOG/Captures/MITO/4_trimal/gt6_newID_aligned480sequences.fasta \
 -gt 0.6

################################# OPTIONS
# * - gt 0.6 -->  Removes all positions in the alignment with gaps in 40% or more of the sequences, 

#######################################################
################################################ IQTREE
# Now we will build the tree using iqtree
source /local/env/envconda.sh
conda activate /groups/Paleogenomics/ENV/iqtree 

iqtree -s input -m MF #this will only find the best model, no tree building (modelfinder)
#then, when the model is found (here TN+F+I+I+R5, according to  BIC criterion), we can run iqtree
iqtree -s /groups/Paleogenomics/DOG/Captures/MITO/4_trimal/gt6_newID_aligned480sequences.fasta\
    --prefix 480samples_Ubt100_gt6 \
    -m TN+F+I+I+R5 -b 1000 -nt AUTO

################################# OPTIONS
# -m TN+F+I+I+R5 --> model chosen by modelfinder
# -b 1000 --> 1000 bootstraps
# -nt AUTO --> let iqtree find itself the number of cores it needs

#######################################################
# Then we can retrieve the .treefile and view it via the tool Figtree on the personnal computer. 
# If we want to modify the names in the tree we can use inkskape.