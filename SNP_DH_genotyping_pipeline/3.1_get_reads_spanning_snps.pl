#thiss cript takes the vcf file that has been filtered int he previous step plus
#the SAM files for both parents that have been aligned to reference genome.
#it then prints two files, one with the reads spanning the snp for this parent
#and the other witht he reads spanning the snp in the other parent. 
#it also prints the snps that could not be covered by both parents to STDOUT
#this will happen when the parent that should be the same as the reference does not have coverage.
#this must be run twice, once for each parent vcf witht he reads in the alterate order

#usage: perl 3.1_get_reads_spanning_snps.pl parentX.vcf parentX.SAM parenY.SAM > parentXsnps_not_covered.txt

use strict;
use warnings;

my $file1 = $ARGV[0];
my $file2 = $ARGV[1];
my $file3 = $ARGV[2];
my $out1 = "reads_for_".$file1."in_otherparent.fasta";
my $out2 = "reads_for_".$file1."in_thisparent.fasta";
#set up hashes for genes and CDS or each chromsomes

my %HOH;
my %HOH2;
open(FILE1, $file1) or die "\ncannot find/open .vcf file\n";

#This sections takes the first file and stores the information as a hash of
#hashes, with the outside being the chromosome and the inside being the start position. 

while (<FILE1>) {
    
    chomp($_);
    my @line = split /\t/, $_;
    
    my @chr = split //, $line[0];
    my $chrom = $chr[1];
    
    my $start = $line[1];
    my $ref = $line[3];
    my $alt = $line[4];
     
    if ($chrom ne 'c') {
        
        $HOH{$line[0]}{$start} = "$ref:$alt";
        
    }
    
}



open(SAM, $file2) or die "Cannot open  file2";
open(OUT1,">$out1") or die "cannot open $out1";

while (<SAM>) {
    my @line = split /\t/, $_;

    my $read = $line[0];
    my $chr = $line[2];
    my $pos = $line[3];
    my $seq = $line[9];

    my $end = $pos+length($seq);

    for (my $i = $pos; $i <= $end-1; $i++){
        if (exists $HOH{$chr}{$i})  {
            
            print OUT1 ">$chr;;$pos;;$read;;$i;;$HOH{$chr}{$i}\n$seq\n";
            #add this to the second hash of hashes that will go onto analyse the file of the chromosomal snps
            #relevant to this parent ***need to add the readname of this into the hash to identify this read as  pair with the other
            $HOH2{$chr}{$i} = $HOH{$chr}{$i};

            delete $HOH{$chr}{$i};
            #this will leave only the snps that couldnt be validated/covered by the other parent!

        }



    }
}


print "printing snp's that couldnt be found in the other parent \n\n\n ******************************\n\n";
for my $type (keys %HOH){
    #print "$type:  ";
    for my $features (keys %{ $HOH{$type} }) {
        print "$type::$features = $HOH{$type}{$features}\n"
    }
}

#then open the other file, the one with the snps in. and do the same as for the other file,
#this time there should be nothing left in the hash. print out two files with the reads for each.
#then print out the snps that couldnt be validated.


open(SAM1, $file3) or die "Cannot open  file3";
open(OUT2,">$out2") or die "cannot open out1";

while (<SAM1>) {
    my @line = split /\t/, $_;

    my $read = $line[0];
    my $chr = $line[2];
    my $pos = $line[3];
    my $seq = $line[9];

    my $end = $pos+length($seq);

    for (my $i = $pos; $i <= $end-1; $i++){
        if (exists $HOH2{$chr}{$i})  {
            
            print OUT2 ">$chr;;$pos;;$read;;$i;;$HOH2{$chr}{$i}\n$seq\n";


            delete $HOH2{$chr}{$i};
 

        }
        }
}

#this should print nothing

print "printing from hash left over after this parent \n\n\n *******************************\n\n";
for my $type (keys %HOH2){
    #print "$type:  ";
    for my $features (keys %{ $HOH2{$type} }) {
        print "$type::$features = $HOH2{$type}{$features}\n"
    }
}

