## this script filters a .vcf to obtain homozygous variants with a depth of at least 10 reads ##
#int his pipeline the script has be ran for each .vcf file produced by 1_....pl
#usage: perl 2_filter_vcf.pl

use strict;
use warnings;

my $file = $ARGV[0];

open(FILE, $file) or die "Cannot open the vcf";

while (<FILE>) {
    my $ori = $_;
    my @line = split /\t/, $_;
    my @stats = split /;/,$line[7];
    my $depth = 0;
    my $allfreq = 0;
    
    #this extracts the 8th column which looks liek DP=5;AF=1.00;MQ=35.00;SB=0
    #we are only interested in getting the depth and checking that and checking
    #the allele frequene to ensure homozygosity
    
    for(@stats){
        my @stat = split /=/, $_;
        if ($stat[0] eq 'DP') {
            $depth = $stat[1];
        } elsif ($stat[0] eq 'AF'){
            $allfreq = $stat[1];
        }
    }
    
##    now check the depth is good and the homozygosity is there and print.

    if ($depth > 10 and $allfreq == 1.00) {
        print $ori;
    }
}

