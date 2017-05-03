# Idotea_genome_project
### Below, you will find the analyses performed to assemble the second version of a Idotea balthica genome assembly.

## The assembly was made using 2 300bp fragment length libraries (one is 2*125 bp reads, one is 2*150 bp reads), and 2 550 bp fragment length libraries (both are 2*300 bp reads)
## This time, the assembly was made using SOAPdenovo.
Configfile can be found here:

(https://github.com/The-Bioinformatics-Group/Idotea_genome_project/blob/master/Assembly_v1/assembly_0002.config)

### Running the steps of SOAPdenovo assembly individually with the sparse_pregraph option:

>SOAPdenovo-127mer sparse_pregraph -s assembly_0002.config -K 67 -z 1000000000 -p 16 -R -o Idotea_SOAP_assembly_0002
>SOAPdenovo-127mer contig -g Idotea_SOAP_assembly_0002 -R
>SOAPdenovo-127mer map -s assembly_0002.config -g Idotea_SOAP_assembly_0002
>SOAPdenovo-127mer scaff -g Idotea_SOAP_assembly_0002 -F

### SOAP worked this time.

Statistics of the assembly are here:
(https://github.com/The-Bioinformatics-Group/Idotea_genome_project/blob/master/Assembly_v2_SOAP/Idotea_SOAP_assembly_0002.scafSeq_assemblyStats.txt)

All assemblyStats files were generated using assemblathon_stats.pl, assuming a 1 Gbp haploid genome size. For example:

>~/scripts/assemblathon_stats.pl Idotea_SOAP_assembly_0002.scafSeq -genome_size 1000000000 > Idotea_SOAP_assembly_0002.scafSeq_assemblyStats.txt

### Then, pruning the assembly to remove scaffolds shorter than 200 bases:

>~/scripts/prune_fasta.pl Idotea_SOAP_assembly_0002.scafSeq 200 5000000000 > Idotea_SOAP_assembly_0002_minLength200.fasta

The script is here:
(https://github.com/The-Bioinformatics-Group/Idotea_genome_project/blob/master/Assembly_v2_SOAP/prune_fasta.pl)

Stats of the pruned assembly are here:
(https://github.com/The-Bioinformatics-Group/Idotea_genome_project/blob/master/Assembly_v2_SOAP/Idotea_SOAP_assembly_0002_minLength200.fasta_assemblyStats.txt)

### In order to remove redundant contigs/scaffolds (perhaps 2 heterozygous alleles being saved as different contigs), the untrimmed assembly was put through the redundans pipeline:

> module load bwa/v0.7.13
> ../redundans/redundans.py -v -i ../5_150827_AC7GAYANXX_P2038_201_1.fastq ../5_150827_AC7GAYANXX_P2038_201_2.fastq ../P3755_forward_paired.fastq ../P3755_reverse_paired.fastq ../P4454_101_S1_L001_R1_001.fastq ../P4454_101_S1_L001_R2_001.fastq ../P4454_101_S1_L002_R1_001.fastq ../P4454_101_S1_L002_R2_001.fastq -f Idotea_SOAP_assembly_0002.contig -o test/run3 -t 4 --identity 0.95 --overlap 0.75 --minLength 200 --noscaffolding --nogapclosing

### Prep the redundans output to be used as input by SOAP:

>/nobackup/data7/pierre/prepare-src_SOAP/finalFusion -D -K 67 -c contigs.reduced.fa -g Idotea_0002_reduced -p 4

### Then, run scaffolding in SOAP once more:

>SOAPdenovo-127mer scaff -g Idotea_0002_reduced.fasta -F

### The statistics of the reduced assembly are here:

(https://github.com/The-Bioinformatics-Group/Idotea_genome_project/blob/master/Assembly_v2_SOAP/Idotea_0002_reduced_assemblyStats.txt)

### Also, pruning the assembly based on minimum scaffold length, using 1 kb and 3 kb to compare.

>~/scripts/prune_fasta.pl Idotea_0002_reduced.scafSeq 1000 5000000000 > Idotea_0002_reduced_pruned1kb.fasta

(https://github.com/The-Bioinformatics-Group/Idotea_genome_project/blob/master/Assembly_v2_SOAP/Idotea_0002_reduced_pruned1kb_assemblystats.txt)

>~/scripts/prune_fasta.pl Idotea_0002_reduced.scafSeq 3000 5000000000 > Idotea_0002_reduced_pruned3kb.fasta

(https://github.com/The-Bioinformatics-Group/Idotea_genome_project/blob/master/Assembly_v2_SOAP/Idotea_0002_reduced_pruned3kb_assemblystats.txt)

### As the 1kb-pruned assembly was close to the estimated genome size (1 Gbp), and the 3kb-pruned one was significantly smaller, it was decided to keep working with the 1kb-pruned one.

