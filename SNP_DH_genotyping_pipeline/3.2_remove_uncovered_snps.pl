#this script takesthe custom output from the previous STDOUT and removes the snps in the VCF file
#that could not be covered by reads in both parents


# usage: perl 3.2_remove_uncovered_snps.pl parentXsnps_not_covered.txt parentx_filtered.vcf > parentXsnpscoveredinboth.vcf

use strict;
use warnings;

my $vcf = $ARGV[0];
my $snp = $ARGV[1];

open(VCF, $vcf) or die "cannot open custom txt file";

my %HOH;

while (<VCF>) {
    $_ =~ s/\s+//g;
    my ($chr , $starts) = split /::/, $_;
    my ($start , $allele) = split /=/, $starts;
    
    $HOH{$chr}{$start} = $allele;
    
    
}


open(SNP, $snp) or die "cannot open vcf file";

while (<SNP>) {
    my $ori = $_;
    my @line = split /\t/, $_;
    my $chr = $line[0];
    my $start = $line[1];
    
    if (exists $HOH{$chr}{$start}) {
    #print $ori;
    } else {
        print $ori;
    }
    
    
}
