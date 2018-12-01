my $file = $ARGV[0];

open(FILE, $file);

while(<FILE>){
    my ($chr, $pos, $p1, $p2) = split /\t/, $_;
    print "$chr\t$pos\t$p1\t$p2\n";
    
}