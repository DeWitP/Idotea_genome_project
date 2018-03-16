# Idotea_genome_project
### This page describes the work done for the Idotea balthica genome assembly after PacBio sequencing.

The raw data is located on Albiorix, here:
/proj/data13/idotea/Idotea_PacBio/rawdata

## A first PacBio only assembly, using FALCON, was unsuccessful, yielded an assembly of 152 Mb (estimated genome size 1Gb).
The Falcon assembly is here: /proj/data13/idotea/Idotea_PacBio/assembly/

## So, it was decided to try a hybrid assembly approach, combining the pre-existing Illumina assembly with the PacBio data, and then scaffolding the output with the available 10x Chromium data.

## First, need to convert the PacBio h5 files to something readable (fastq):

see convert_h5_to_fastq.sge

## Then, for PBJelly, need to separate the fastq files to fasta with additional .qual file.

see fastaqual.sge for that process.

## Now, these files we can use as input for a hybrid assembly using PBJelly. 

# First, need to generate an .xml config file for PBJelly. It is located here, called Ibalt_PBJelly.xml
# Also, for the setup stage, creating the sam file but without the submit cluster step: Ibalt_PBJelly_noclust.xml

#Then, doing the PBJelly steps:

qsub PBJ.sge

### WARNING: This script created bash scripts on the compute nodes which kept running jobs for a long time without being visible in the queue system!!!
### SO, make sure no-one else is running analyses on the same node as it will crash the node.

# And, only submit one line of the submit script at a time, and wait for it to finish before submitting the next one.

## This actually produced a decent result!

Statistics of the assembly are found in assemblystats_PBJelly.txt

## Now, 10x scaffolding:

Using the submit script PBjelly_10x_scaffolding.sge

# Adjusting the assembly using LINKS (Ran this on the DNA server instead as there were problems installing on Albiorix).

touch empty.fof

/usr/local/links_v1.8.5/LINKS -f Idotea_PBJelly_ArcsRound1.fasta -s empty.fof -k 20 -b Idotea_PBJelly_ArcsRound1.fasta.scaff_s95_c5_l0_d0_e30000_r0.05 -z 200 -d 2000 -l 1

## Ran arcs one more time, remapping the 10x data to the new assembly, and then scaffolding, but the output was identical to the input.
so, the output file is called Idotea_PBJelly_ArcsRound2.fasta

## This means that it is meaningless to keep iterating. Proceeding to the next step instead.

### The final step is to fill assembly gaps using Abyss-sealer:

Using the submit script Ibalt_gapFill.sge

This uses all 4 Illumina libraries to fill gaps.
The final output assembly is here:

/proj/data13/idotea/Idotea_latest_assemblies/Idotea_PBJelly_ArcsRound2_sealed_scaffold.fa

Assembly statistics are in Idotea_PBJelly_ArcsRound2_sealed_scaffold_assemblyStats.txt

## Now, this assembly is as good as I can make it. This is passed on to the MAKER automated gene model prediction software.
