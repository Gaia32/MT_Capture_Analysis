import sys
from Bio import SeqIO

# ######################################################################
# def getSpecificSamples(file):
#     '''With this funtion, we parse the file containing all sequences into a "record" with 
#     an "id" and "seq", if the IDs that are in the file "names90" are found in the "allseqs" 
#     file, the IDs and its sequence are both put into a new file "newSeqs"'''
#     # "233ALLCROC_multiFasta.fa" : This is the file containing all samples
#     all_fa="233ALLCROC_multiFasta.fa"
#     # "IDsSamplesWith90%.txt" : This is the file contaçning the IDs of the samples we want to keep
#     with open("IDsSamplesWith90%.txt", "r") as fh:
#         names90=[line.rstrip("\n") for line in fh.readlines()]
#         with open(file, "w") as newSeqs:
#             with open(all_fa) as allseqs:
#                 for record in SeqIO.parse(allseqs, "fasta"):
#                     for name in names90:
#                         if name in record.description:
#                             newSeqs.write(">")
#                             newSeqs.write(str(record.id))
#                             newSeqs.write("\n")
#                             newSeqs.write(str(record.seq))
#                             newSeqs.write("\n")
# # getSpecificSamples("142CROCsup90_multiFasta.fa")

######################################################################
def changeSeqIDs(infile,outfile,names):
    '''In the next function, we read a table given in input containing one column with the old names and the second column with the new names. Then we create a dictionnary composed of "oldName : newName". 
    For each sequence id, we look for it in the dict, then we replace the 
    record.id with the corresponding newID'''
    namesHandler = {}
    for line in open(names,'r', encoding="utf-8").readlines(): # read in this file, split it into a dict
        line_split = line.strip('\n').split('\t')
        namesHandler[line_split[0]] = line_split[1]

    # open a file for the output
    output_file = open(outfile,'w', encoding="utf-8")
    # create an iterable to hold the new id
    new_seq = []

    for record in SeqIO.parse(open(infile,'r', encoding="utf-8"),'fasta'):
        new_record_name = namesHandler[record.id] 
        record.id = new_record_name
        record.name = ''
        record.description = ''
        new_seq.append(record)
        # write the whole thing out
    SeqIO.write(new_seq, output_file, 'fasta')
    