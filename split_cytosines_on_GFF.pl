use strict;
use warnings;
use Data::Dumper;


#perl script.pl <gff> <genome matrix>
open(my $fh, $ARGV[0]);

my %gene_hash;

while (<$fh>) {
    my $line = $_;
    
    my @lines = split /\t/, $line;
    
    my ($chr) =  $lines[0];
    
    my $start = $lines[3];
    
    my $end = $lines[4];
      my $type = $lines[2];
      if ($type eq "gene") {
              $gene_hash{$chr}{$start} = "$end";
      }
      

      
}



open(my $fh2, $ARGV[1]);
while (<$fh2>) {
    chomp($_);
    my ($chr, $start, $strand, $m, $u, $cont, $cont2) = split /\t/, $_;
    my $location = "IG";
    my $position = "IG";
    my $mr = $m / ($m + $u);
    
    
    foreach my $chr (keys %gene_hash){
        foreach my $gstart (keys $gene_hash{$chr}){
            if ($start < $gstart-2000) {
                next;
            }if ($start > $gene_hash{$chr}{$gstart}+2000) {
                next;
            }
            
            my $up = 'FALSE';
            my $gend = $gene_hash{$chr}{$gstart};
            my $before= $gstart - 2000;
            my $after = $gend + 2000;
            
 
            if ($start >= $gstart && $start <= $gend) {
                $location = "GENE";
                my $gene_length = $gend - $gstart;
                my $gloc = $start - $gstart;
                my $perc = ((($gloc/$gene_length)*1000)*2);
                $position = $perc +2000;
                
                
            }
            elsif ($start < $gstart && $start > $before) {
                $location = "UP";
                $position = $start - $before;
            }
            

            
            
            elsif ($start > $gend && $start < $after) {
                $location = "DOWN";
                $position = $start -$gend + 3000;
            }
            
            
            
        }
    }
    print "$chr\t$start\t$mr\t$location\t$position\t$cont\n";
    



}