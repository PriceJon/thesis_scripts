use strict;
use warnings;
use Data::Dumper;
#this script will split the in the offspring depending on the parent they came from 


#build the contingency table

my %contingency;

# p1 p2 flag observed = parent
my %hoa;

#each possible snp is shown  below as p1 p2 topstrandp1 topstrandp2 bottomp1 bottomp2
#when p1 and p2 are the bases that are represented at this loci
# topx and bottomx are the possible alleles of the child depending on the strand
$hoa{1} =  ['G','C','G','CT','CT','G'];
$hoa{2} = ['C','G','CT','G','G','CT'];
$hoa{3}  = ['A','T','A','T','T','A'];
$hoa{4} = ['T','A','T','A','A','T'];
$hoa{5}  = ['G','T','G','T','CT','A'];
$hoa{6}  = ['T','G','T','G','A','CT'];
$hoa{7} = ['C','A','CT','A','G','T'];
$hoa{8}  = ['A','C','A','CT','T','G'];


foreach my $array (keys %hoa){
    
    my @vals = @{ $hoa{$array}};
        my $p1 = $vals[0];
    my $p2 = $vals[1];
    my $t1 = $vals[2];
    my $t2 = $vals[3];
    my $b1 = $vals[4];
    my $b2 = $vals[5];

    my $top = 99;
    my $bottom = 83;
    
    $contingency{$p1}{$p2}{$top}{$t1} = 1;
    $contingency{$p1}{$p2}{$top}{$t2} = 2;
    $contingency{$p1}{$p2}{$bottom}{$b1} = 1;
    $contingency{$p1}{$p2}{$bottom}{$b2} = 2;
    
}

#prints all members of the table:
#print Dumper(%contingency);
#a parental split can be determieqd via the hash:
#print "\n\n$contingency{G}{C}{99}{G}\n\n";


#now read in the .snps file at store in hoh;

my $snp = $ARGV[0];
open(SNP,$snp) or die "can't open .snps file : $snp";

my %snph;

while (<SNP>) {
    chomp($_);
    my ($chr, $pos, $p2, $p1) = split /\t/, $_;
     #print "$p1\t$p2\n";
    
    #add to hash if they have solutions
    if (($p1 eq 'G' and $p2 eq 'A')){
    }elsif($p1 eq 'A' and $p2 eq 'G'){
    }elsif($p1 eq 'C' and $p2 eq 'T'){
    }elsif($p1 eq 'T' and $p2 eq 'C') {
    
    }else {
         $snph{$chr}{$pos} = "$p1::$p2";
    }
}

#for my $type (keys %snph){
#    print "$type:  ";
#    for my $features (keys %{ $snph{$type} }) {
#        print "$type::$features = $snph{$type}{$features}\n"
#    }
#}


my $file3 = $ARGV[1];


open(SAM1, $file3) or die "Cannot open  file3";
open(P1,">A2_genome_of_hybrid.sam") or die "cannot open p1 to write";
open(P2,">D2_genome_of_hybrid.sam") or die "cannot open p2 to write";

while (<SAM1>) {   
    my $sec1 = $_;
   my ($read, $c, $start, $seq, $flag, $end) = getinfo($_);
    my $sec = <SAM1>;
    my ($read2, $c2, $start2, $seq2, $flag2, $end2) = getinfo($sec);
    

    
    my $read1p = isSnpPresent($c, $start, $end, $seq, $flag);
    my $read2p = isSnpPresent($c2, $start2, $end2, $seq2, $flag2);
    
    if ($read1p == 1 or $read2p == 1) {
        print P1 "$sec1$sec";
    }elsif ($read1p == 2 or $read2p == 2) {
        print P2 "$sec1$sec";
    }
    

    
    
        
    
    
}



sub getinfo{
    my @line = split /\t/, $_;

    my $read = $line[0];
    my @chr = split //, $line[2];
    my $start = $line[3];
    my $seq = $line[9];
    
    my $flag = $line[1];
        if ($flag == 147) {
        $flag = 99;
    }elsif($flag == 163){
        $flag = 83;
    }
        
    my $length = length($seq);
    my $end = $start + $length;
    return ($read, $chr[1], $start, $seq, $flag, $end);
}

sub  isSnpPresent{
    my ($c, $start, $end, $seq, $flag) = @_;
    
    my @seqs = split//, $seq;
    
     if ($c ne 'c') {
        
    
    for (my $i = $start; $i <= $end -1   ; $i++){
        my $j = $i - $start;
        #print "start = $start\tend = $end\tposition = $j\tbase = $seqs[$j]\n";
        if (exists $snph{$c}{$i}) {
            #print"\n\n***********************\nbase here = $seqs[$j]\nparental = $snph{$c}{$i}\n*********************\n";
            my ($p1, $p2) = split /::/ ,$snph{$c}{$i};
            my $base = $seqs[$j];
            
            if ($p1 eq 'G' and $p2 eq ' C' and $flag = 99 and ($seqs[$j] eq 'C' or $seqs[$j] eq 'T')){
                $base = 'CT';
            }if ($p1 eq 'C' and $p2 eq 'G' and $flag = 99 and  ($seqs[$j] eq 'C' or $seqs[$j] eq 'T')){
                $base = 'CT';
            }if ($p1 eq 'C' and $p2 eq 'A' and $flag = 99 and ($seqs[$j] eq 'C' or $seqs[$j] eq 'T')){
                $base = 'CT';
            }if ($p1 eq 'A' and $p2 eq 'C' and $flag = 99 and ($seqs[$j] eq 'C' or $seqs[$j] eq 'T')){
                $base = 'CT';
            }if ($p1 eq 'G' and $p2 eq 'C' and $flag = 83 and ($seqs[$j] eq 'C' or $seqs[$j] eq 'T')){
                $base = 'CT';
            }if ($p1 eq 'C' and $p2 eq 'G' and $flag = 83 and ($seqs[$j] eq 'C' or $seqs[$j] eq 'T')){
                $base = 'CT';
            }if ($p1 eq 'G' and $p2 eq ' T' and $flag = 83 and ($seqs[$j] eq 'C' or $seqs[$j] eq 'T')){
                $base = 'CT';
            }if ($p1 eq 'T' and $p2 eq ' G' and $flag = 83 and ($seqs[$j] eq 'C' or $seqs[$j] eq 'T')){
                $base = 'CT';
            }
            
            #print"parent is $contingency{$p1}{$p2}{$flag}{$base}";
            #print"$p1\t$p2\t$flag\t$base";
            return $contingency{$p1}{$p2}{$flag}{$base};
        }
        
        
    }
    
    
    
    }
    
    
}
