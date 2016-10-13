# Idotea_genome_project
### Below, you will find the analyses performed to assemble the first version of a Idotea balthica genome assembly.

## The assembly was made using 2 300bp fragment length libraries (one is 2*125 bp reads, one is 2*150 bp reads), and 2 550 bp fragment length libraries (both are 2*300 bp reads)
## First, production of preQC report:

(https://github.com/The-Bioinformatics-Group/Idotea_genome_project/blob/master/Assembly_v1/Idotea_4libs_preqc_report.pdf)
--------------------------------------

## Then, I tried producing a de novo assembly using SOAP.
Configfile can be found here:

(https://github.com/The-Bioinformatics-Group/Idotea_genome_project/blob/master/Assembly_v1/assembly_0002.config)

### Running the first step of SOAPdenovo assembly with the sparse_pregraph option:

>SOAPdenovo-127mer sparse_pregraph -s assembly_test.config -K 67 -z 1000000000 -p 16 -R -o Idotea_SOAP_assembly_test

### This did not work for some reason, SOAP froze up.

### Trying instead to produce an assembly using CLC, using minimum contig length 200:

>export TMPDIR=/nobackup/data7/pierre/tmp
>module load CLC-Assembly-cell/v5.0.1

>clc_assembler -o Ibaltica_genome_v1_0.fasta -f Ibaltica_genome_v1_0.gff -m 200 -w 64 --cpus 24 -v \
-q 5_150827_AC7GAYANXX_P2038_201_1_u.fastq -q 5_150827_AC7GAYANXX_P2038_201_2_u.fastq \
-q P3755_forward_unpaired.fastq -q P3755_reverse_unpaired.fastq \
-q P4454_101_S1_L001_R1_001_u.fastq -q P4454_101_S1_L001_R2_001_u.fastq \
-q P4454_101_S1_L002_R1_001_u.fastq -q P4454_101_S1_L002_R2_001_u.fastq \
-p fb ss 180 600 -q -i 5_150827_AC7GAYANXX_P2038_201_1.fastq 5_150827_AC7GAYANXX_P2038_201_2.fastq \
-p fb ss 160 560 -q -i P3755_forward_paired.fastq P3755_reverse_paired.fastq \
-p fb ss 180 800 -q -i P4454_101_S1_L001_R1_001.fastq P4454_101_S1_L001_R2_001.fastq \
-p fb ss 180 800 -q -i P4454_101_S1_L002_R1_001.fastq P4454_101_S1_L002_R2_001.fastq

### Statistics for the assembly v 1.0 are here: (https://github.com/The-Bioinformatics-Group/Idotea_genome_project/blob/master/Assembly_v1/Idotea_assembly_v1_0_stats.txt)

### To assess completeness of the assembly, I then tried mapping all the 2b-RAD loci from the BONUS BAMBI project (https://github.com/DeWitP/BONUS_BAMBI_IDOTEA), generated from the same individual, against the assembly.
### Results can be found here:

(https://github.com/The-Bioinformatics-Group/Idotea_genome_project/blob/master/Assembly_v1/mapping_summary_RADloci_vs_genome_v1_0.txt)

### Turns out that only about 2/3 of the RAD loci mapped to the genome. Hypothesis is that the rest of them would map, if the minimum contig length was smaller.

### So, making a new assembly using CLC (v 1.2), using minimum contig length 125 (same as the shortest read length):

>export TMPDIR=/nobackup/data7/pierre/tmp
>module load CLC-Assembly-cell/v5.0.1

>clc_assembler -o Ibaltica_genome_v1_2.fasta -f Ibaltica_genome_v1_2.gff -m 125 -w 64 --cpus 24 -v \
-q 5_150827_AC7GAYANXX_P2038_201_1_u.fastq -q 5_150827_AC7GAYANXX_P2038_201_2_u.fastq \
-q P3755_forward_unpaired.fastq -q P3755_reverse_unpaired.fastq \
-q P4454_101_S1_L001_R1_001_u.fastq -q P4454_101_S1_L001_R2_001_u.fastq \
-q P4454_101_S1_L002_R1_001_u.fastq -q P4454_101_S1_L002_R2_001_u.fastq \
-p fb ss 180 600 -q -i 5_150827_AC7GAYANXX_P2038_201_1.fastq 5_150827_AC7GAYANXX_P2038_201_2.fastq \
-p fb ss 160 560 -q -i P3755_forward_paired.fastq P3755_reverse_paired.fastq \
-p fb ss 180 800 -q -i P4454_101_S1_L001_R1_001.fastq P4454_101_S1_L001_R2_001.fastq \
-p fb ss 180 800 -q -i P4454_101_S1_L002_R1_001.fastq P4454_101_S1_L002_R2_001.fastq

### Statistics for the assembly v 1.2 are here: (https://github.com/The-Bioinformatics-Group/Idotea_genome_project/blob/master/Assembly_v1/Idotea_assembly_v1_2_stats.txt)

### To assess completeness of the assembly, I then tried mapping all the 2b-RAD loci from the BONUS BAMBI project (https://github.com/DeWitP/BONUS_BAMBI_IDOTEA), generated from the same individual, against the assembly.
### Results can be found here:

(https://github.com/The-Bioinformatics-Group/Idotea_genome_project/blob/master/Assembly_v1/summarystats_map_vs_1_2.txt)

### Now, 98.4 % of the RAD loci map to at least one position in the assembly. 

###Next step will be to try to 