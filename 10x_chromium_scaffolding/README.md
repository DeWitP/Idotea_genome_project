# Idotea_genome_project
### Below, you will find the analyses performed to scaffold the Idotea balthica assembly v2 (assembled with SOAP, then redundancy-checked with redundans and pruned to remove scaffolds < 1kb) using 10x Chromium data.

### The 10x chromium data was prepared by dividing DNA into 4 aliquots, which were prepared independently, then multiplexed and sequenced together in an Illumina HiSeq2500, paired-end, 150 bp. 

The statistics of the Supernova assembly are here:

(https://github.com/The-Bioinformatics-Group/Idotea_genome_project/blob/master/10x_chromium_scaffolding/10x_Idotea_output.txt)


### Tried 2 different approaches, fragScaff (Mostovoy et al. 2016) and Arcs (Yeo et al. 2017). In addition, NGI tried the supernova pipeline to assembly only the 10x data, but that produced an assembly which was only 40 Mb. 

fragScaff did not work, all it did was to add thousands of scaffolds with only N's to the assembly. It was also rather difficult to change the read group information to include the 10x barcode rather than the sample name. 
I will not describe the fragScaff pipeline more here, but commands used are available upon request.

### ARCS:

First, need to prepare the input files with longranger:

>module load longranger/v2.1.2
>longranger basic --fastqs /nobackup/data7/pierre/10x/A.Blomberg_16_12/Sample_P6353_101_S1 --sample P6353 > Sample_1.barcoded.fastq

Output from LongRanger:
(https://github.com/The-Bioinformatics-Group/Idotea_genome_project/blob/master/10x_chromium_scaffolding/longranger_stats.txt)

### The output files from longranger has a identifier line in this format:

@ST-E00266:165:H5VY5ALXX:1:1204:1499:54858 BX:Z:AAGATAGCATGGATTC-1

Where the BX:Z: tag is the 16 nucleotide barcode sequence. However, Arcs requires the identifier to be IDENTIFIER_BARCODE. So, need to modify the files.

>sed -E "s/\tBX:Z:/_/" Sample1.barcoded.fastq > Sample1.ID_barcode.fastq

..etc for all the 4 samples.

### Another problem is that the barcode sequence ends with "-1", which is not supported by Arcs. So, replacing the -1 with an extra nucleotide instead (different for the 4 samples, to allow mixing):

>sed -i -E "s/([ATCG]+)-1$/\1A/" Sample1.ID_barcode.fastq
>sed -i -E "s/([ATCG]+)-1$/\1T/" Sample2.ID_barcode.fastq
>sed -i -E "s/([ATCG]+)-1$/\1C/" Sample3.ID_barcode.fastq
>sed -i -E "s/([ATCG]+)-1$/\1G/" Sample4.ID_barcode.fastq

Now, the identifier line is IDENTIFIER_BARCODE, with a 17 base barcode sequence. 

### Starting by mapping the 10x reads against the 1kb pruned assembly with bwa mem:

>module load bwa/v0.7.13
>bwa index Idotea_0002_reduced_pruned1kb.fasta
>bwa mem -p -t 12 -C -R '@RG\tID:Sample1\tSM:Sample1' Idotea_0002_reduced_pruned1kb.fasta Sample1.barcoded.fastq > Sample1_vs_1kb.sam
>bwa mem -p -t 12 -C -R '@RG\tID:Sample2\tSM:Sample2' Idotea_0002_reduced_pruned1kb.fasta Sample2.barcoded.fastq > Sample2_vs_1kb.sam
>bwa mem -p -t 12 -C -R '@RG\tID:Sample3\tSM:Sample3' Idotea_0002_reduced_pruned1kb.fasta Sample3.barcoded.fastq > Sample3_vs_1kb.sam
>bwa mem -p -t 12 -C -R '@RG\tID:Sample4\tSM:Sample4' Idotea_0002_reduced_pruned1kb.fasta Sample4.barcoded.fastq > Sample4_vs_1kb.sam

### Then, convert to bam and sort:

>~/scripts/convert_to_bam.sh

Script is here: 
(https://github.com/The-Bioinformatics-Group/Idotea_genome_project/blob/master/10x_chromium_scaffolding/convert_to_bam.sh)

samples.txt:
Sample1_vs_1kb.sorted.bam
Sample2_vs_1kb.sorted.bam
Sample3_vs_1kb.sorted.bam
Sample4_vs_1kb.sorted.bam

### Now, we can run Arcs:

>./arcs -f Idotea_0002_reduced_pruned1kb.fasta -a samples.txt -s 90 -c 2 -l 0 -z 100 -m 10-50000 -d 0 -e 200 -r 0.05 -i 17 -v 1

### In order to be able to join contig together, it was necessary to lover the settings especially for the minimum number of reads mapping to form a link (-c) and the length of the contig ends considered for assignment of contig orientation (as the contigs are much shorter than recommended by the software) 

## Run python script makeTSVfile.py to convert ARCS graph output to LINKS XXX.tigpair_checkpoint file format

>./makeTSVfile.py Idotea_0002_reduced_pruned1kb.fasta.scaff_s90_c2_l0_d0_e200_r0.05_original.gv Idotea_0002_reduced_pruned1kb.fasta.c2_e200_r0.05.tigpair_checkpoint.tsv Idotea_0002_reduced_pruned1kb.fasta

## Run LINKS with generated XXX.tigpair_checkpoint file as input
## NOTE: Did this on DNA rather than Albiorix, as I couldn't get LINKS to work on Albiorix.

>touch empty.fof
>/usr/local/links_v1.8.5/LINKS -f Idotea_0002_reduced_pruned1kb.fasta -s empty.fof -k 20 -b Idotea_0002_reduced_pruned1kb.fasta.c2_e200_r0.05 -z 200 -d 2000 -l 1

### Needed to lower the parameter for min links used for scaffolding to 1, as no link was present more than once in the TSV file..

### Saving the Arcs-scaffolded assembly as: Idotea_0002_reduced_pruned_arcs.fasta

Statistics of the Assembly:
(https://github.com/The-Bioinformatics-Group/Idotea_genome_project/blob/master/10x_chromium_scaffolding/Idotea_0002_reduced_pruned_arcs_assemblyStats.txt)


### Finally: Filling gaps using Sealer, using the original Illumina data (4 libraries, paired end).

>module load Abyss/v2.0.2
>abyss-sealer -v -j 14 -b40G -k90 -k80 -k70 -k60 -k50 -k40 -k30 -o Idotea_0002_reduced_pruned_arcs -S Idotea_0002_reduced_pruned_arcs.fasta ../*.fastq

### Final file called Idotea_0002_reduced_pruned_arcs_scaffold.fa 

Sealer output: 
(https://github.com/The-Bioinformatics-Group/Idotea_genome_project/blob/master/10x_chromium_scaffolding/Idotea_0002_reduced_pruned_arcs_log.txt)

Assembly Statistics:
(https://github.com/The-Bioinformatics-Group/Idotea_genome_project/blob/master/10x_chromium_scaffolding/Idotea_0002_reduced_pruned_arcs_scaffold.fa.assemblyStats.txt)

##That is as good as the assembly is going to get until PacBio data becomes available.
