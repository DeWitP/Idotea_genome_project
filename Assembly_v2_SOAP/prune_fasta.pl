#!/usr/bin/perl
#Extract sequences from fasta file based on length.
#Input is fasta file, upper and lower sequence length.
#Tomas Larsson, 19 September 2014

use strict;
use warnings;
use diagnostics;

#Variable declarations
my$infilePath = $ARGV[0];   #Infile
my$minLength = $ARGV[1];    #Minimum length of sequence to report
my$maxLength = $ARGV[2];    #Maximum length of sequence to report

my$seqID = "";
my$seq = "";

open INFILE, "$infilePath" or die "Could not open file: $! \n";
while(<INFILE>) {
    chomp;
    if ($_ =~ /^>/) {
        if (length($seq) >= $minLength && (length($seq) <= $maxLength)) {
          # print $seqID . "\t" . length($seq) . "\n"; #print id and add length of sequence in header
            print $seqID . "\n"; #print id without adding length
            print $seq, "\n";
        }
        $seq = "";
        $seqID = $_;
    } else {
        $seq = $seq . $_;
    }
}

if (length($seq) >= $minLength && (length($seq) <= $maxLength)) {
          # print $seqID . "\t" . length($seq) . "\n"; #print id and add length of sequence in header
            print $seqID . "\n"; #print id without adding length
            print $seq, "\n";
}

close INFILE;
exit;
