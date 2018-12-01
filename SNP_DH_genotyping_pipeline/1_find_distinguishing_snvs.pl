#This script takes two .vcf files, one for each parent, loads the first into memory
#then identifies snps that exist in one parent and don't exist in the other.
#the logic being that if an snp doesnt exist in the other ti must be the same as
#the reference and therefore a distinguishing SNP.
#the script has to be ran both ways i.e one for each parent.

#usage : perl 1_find_distinguishing_snvs.pl parent1.vcf parent2.vcf

use strict;
use warnings;

my $file1 = $ARGV[0];


#set up hashes for genes and CDS or each chromsomes

my %HOH;

open(FILE1, $file1) or die "\ncannot find/open gff file\n";

#This sections takes the first file and stores the information as a hash of
#hashes, with the outside being the chromosome and the inside being the start position. 

while (<FILE1>) {
    
    chomp($_);
    my @line = split /\t/, $_;
    
    my @chr = split //, $line[0];
    my $chrom = $chr[1];
    
    my $start = $line[1];
     
    if ($chrom ne 'c') {
        
        $HOH{$line[0]}{$start} = 0;
        
    }
}


my $file2 = $ARGV[1];

open(FILE2, $file2) or die "Cannot open  file2";

while (<FILE2>) {
        my $ori = $_;
    chomp($_);
    my @line = split /\t/, $_;
    
    my @chr = split //, $line[0];
    my $chrom = $chr[1];
    
    my $start = $line[1];
    
        if ($chrom ne 'c'){
        if (exists $HOH{$line[0]}{$start})  {           
        }else{
            print "$ori";
        }    
}
    
}
