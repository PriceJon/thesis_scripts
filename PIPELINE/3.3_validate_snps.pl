#this script will verify the snps of the parents by manually aligning the reads to the
#reference genome and then printing the two reads and the section of the referenc genome out

##usage : perl 3.3_verify_snps_on_reference.pl reference.fasta reads1.fasta reads2.fasta parentX.verfiy parentx.snps

#reads file and reference file must be single line fastas!!!!


use strict;
use warnings;

my $ref = $ARGV[0];

open(REF, $ref) or die "cannot open $ref";

#hash for the reference
my %refhash;


while (<REF>) {
    
    #header is first line so get that
    my $head = $_;
    my $chr;
    #get chromosome number, ignore if a scaffold and end the hash making
    if ($head =~ m/(C[1-9])/){
        $chr = $1;
    }else{
        last;
    }
    #the sequence is the second line so get this
    my $seq = <REF>;
    #get the chromsome number from the match.
    my ($let, $chrom) = split //, $chr;
    #turn the sequence of the chromsome into array
    my @seqs = split //, $seq;
    #put it into the hash with the chromsome as key and the sequence array as the value
    $refhash{$chrom} = [ @seqs ];
    #check how long it takes to read in a chromsome/check it works
    #print "\n\n\n$chrom\t done!\n\n";
}



# this is where is gets "wierd" the program has to read in two files containing reads
#on with reads spannign the snp for this parent and one for the other parent. 
my $this = $ARGV[1];
my $other = $ARGV[2];

my $verify = $ARGV[3];
my $snplist = $ARGV[4];

open(VER, ">$verify") or die "cannto write to verify file";
open(SNP, ">$snplist") or die "cannot write to snp list";
print SNP "Chr\tPos\tOtherPbase\tThispbase\n";

open(THIS, $this) or die "cannot open $this";
open(OTHER, $other) or die "cannot open $other";

while (not eof THIS and not eof OTHER) {
    my $thisname = <THIS>;
    my $othername = <OTHER>;
    my $thisseq = <THIS>;
    chomp($thisseq);
    my $otherseq = <OTHER>;
    chomp($otherseq);
    #print $thisseq."\n";
    
    my ($thischr, $thisstart, $thisread, $thissnp, $thisbase) = split /;;/, $thisname;
    my ($otherchr, $otherstart, $otherread, $othersnp, $otherbase) = split /;;/, $othername;
    my ($w, $q, $c) = split //, $thischr;

    my @thiseqs = split //, $thisseq;
    my @otherseqs = split //, $otherseq;
    my ($refb , $altb) = split /:/, $thisbase;
    
    chomp ($altb);
    my $thisrlength = length($thisseq);
    my $otherrlength = length($otherseq);
    #print $thisrlength."\n";
    
     my $thispos;
    my $otherpos;
    
    my $start;
    my $snppos;
    if ($thisstart <= $otherstart) {
        $start = $otherstart;
        #$snppos = $thissnp - $start;
        $thisstart = $otherstart - $thisstart;
        #$thispos = $thispos - $thisstart;
        $otherpos = $othersnp - $otherstart;
        $thispos = $otherpos + $thisstart;
        $otherstart = 0;
        
        
    }elsif ($otherstart <= $thisstart){
        $start = $thisstart;
         $snppos = $thissnp - $start;
        $otherstart = $thisstart - $otherstart;
        #$otherpos = $otherpos - $otherstart;
        $thispos = $thissnp - $thisstart;
        $otherpos = $thispos + $otherstart;
        $thisstart = 0;
        
    }

  
   
 
    
    my $diff = 0;
 
    my $thisfinal = '';
    my $otherfinal = '';
    my $reffinal = '';
    
    for (my $i = $thisstart; $i <= $thisrlength-1; $i++){
        if ($i == $thispos) {
           $thisfinal = join("", ($thisfinal, "-",$thiseqs[$i],"-"));
        }else{
            $thisfinal = join("", ($thisfinal, $thiseqs[$i]));
        }
    }
    
    for (my $i = $start; $i <= $start + $thisrlength; $i ++){
        if ($i == $thissnp) {
            $reffinal = $reffinal."-".$refhash{$c}[$i-1]."-";
        }else{
            $reffinal = $reffinal.$refhash{$c}[$i-1];
        }
    }
    
    for (my $i = $otherstart; $i <= $otherrlength-1; $i++){
        if ($i == $otherpos) {
            $otherfinal = $otherfinal."-".$otherseqs[$i]."-"; 
        }else {
            $otherfinal = $otherfinal.$otherseqs[$i];
        }
    }
    
    
    if ($thiseqs[$thispos] eq $altb and $thiseqs[$thispos] ne $refb) {
        print VER $thisname.":::::".$othername;
        print VER "$start\t".$thisfinal."\n$start\t$reffinal\n$start\t$otherfinal\n";
      
        print SNP "$c\t$thissnp\t$refb\t$altb\n";
      
        
    }
    


    
 

    
    
    
    
}





