# Idotea_genome_project
# In this file, I list commands I have used in the analysis of the Idotea genome sequence data.

# This first section deals with the 300 bp insert size library produced in September 2015. All analyses were performed in the high_mem node of Albiorix. 

---------------------------------------
# First, production of preQC report:

>sga preprocess --pe-mode 1 5_150827_AC7GAYANXX_P2038_201_1.fastq 5_150827_AC7GAYANXX_P2038_201_2.fastq > Idotea.fastq

Parameters:
QualTrim: 0
QualFilter: no filtering
HardClip: 0
Min length: 40
Sample freq: 1
PE Mode: 1
Quality scaling: 2
MinGC: 0
MaxGC: 1
Outfile: stdout
Orphan file: none
Discarding sequences with ambiguous bases
Processing pe files 5_150827_AC7GAYANXX_P2038_201_1.fastq, 5_150827_AC7GAYANXX_P2038_201_2.fastq

Preprocess stats:
Reads parsed:   524213998
Reads kept:     514711656 (0.981873)
Reads failed primer screen:     371 (7.07726e-07)
Bases parsed:   63074997749
Bases kept:     62461044104 (0.990266)
Number of incorrectly paired reads that were discarded: 0
[timer - sga preprocess] wall clock: 2677.66s CPU: 2557.22s

>sga index -a ropebwt --no-reverse -t 16 Idotea.fastq

Building index for Idotea.fastq in memory using ropebwt
         done bwt construction, generating .sai file
[timer - sga index] wall clock: 13525.30s CPU: 63566.39s

>sga preqc -t 16 Idotea.fastq > Idotea.preqc

[timer - sga::preqc] wall clock: 4669.87s CPU: 36390.05s

>sga-preqc-report.py Idotea.preqc /usr/local/bin/SGA-0.10.13/src/examples/preqc/*.preqc

--------------------------------------

# Then, producing a de novo assembly using SOAP.

#Running SOAPdenovo assembly with parameters based on the preQC data (K-mer length 45)

>SOAPdenovo-63mer all -s assembly_0001.config -K 45 -p 16 -R -o Idotea_assembly 1>assembly.log 2>assembly.err

#Rerunning assembly with minContigLength 200, kmer length 57.

>SOAPdenovo-63mer all -s assembly_0001.config -K 57 -p 16 -L 200 -R -o Idotea_assembly_v2 1>assembly_v2.log 2>assembly_v2.err

#Seems the minContigLength flag did NOTHING, need to prune out the very short contigs using Tomas' perl script:

>prune_fasta.pl 200 250000 Idotea_assembly_v2.contig > Idotea_assembly_v2_pruned.fasta

---------------------------------------

# To get an idea of contaminant sequences, BLASTing the 1000 longest contigs in the assembly:

#Grabbing the longest 1000 contigs with tail (already sorted by length by SOAP):

>tail -n 2000 Idotea_assembly_v2_pruned.fasta > L1000.fasta

#BLASTxing the 1000 longest sequences against nr (only first 5000 bases, for speed):

>blastx -query L1000.fasta -db /state/partition1/db/ncbi/nr -num_alignments 10 -num_threads 32 -query_loc 1-5000 -out L1000_BLASTx_to_nr_output.txt

#Mapping short reads with bwa:

>../bwa/bwa index -p Idotea -a is L1000.fasta

>../bwa/bwa aln -n 0.005 -k 5 -t 16 Idotea 5_150827_AC7GAYANXX_P2038_201_1.fastq > Idotea_pairs1.sai

>../bwa/bwa aln -n 0.005 -k 5 -t 16 Idotea 5_150827_AC7GAYANXX_P2038_201_2.fastq > Idotea_pairs2.sai

>../bwa/bwa sampe -a 750 -r '@RG\tID:Idotea\tSM:Idotea\tPL:Illumina' -P Idotea Idotea_pairs1.sai Idotea_pairs2.sai 5_150827_AC7GAYANXX_P2038_201_1.fastq 5_150827_AC7GAYANXX_P2038_201_2.fastq > Idotea_pairs.sam

-------------------------------------------------------------------

