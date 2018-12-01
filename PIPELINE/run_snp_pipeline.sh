#  $1 is the VCF file for parent 1
#  $2 is the VCF file for parent 2
#  $3 is the reads file for parent 1
#  $4 is the reads file for parent 2
#  $5 is the reference


#1 find the snps from the vcf files


perl 1_find_distinguishing_snvs.pl $1 $2 > ${2}_specific.vcf

perl 1_find_distinguishing_snvs.pl $2 $1 > ${1}_specific.vcf

#2 filter the snps

perl 2_filter_vcf.pl ${1}_specific.vcf > ${1}_specific_filtered.vcf

perl 2_filter_vcf.pl ${2}_specific.vcf > ${2}_specific_filtered.vcf



#get reads spaning them

perl 3.1_get_reads_spanning_snps.pl ${1}_specific_filtered.vcf $4 $3 > snps_p1_not_in_p2.txt
# also produces reads_for_$1_specific_filtered.vcfin_otherparent.fasta
#       and reads_for_$1_specific_filtered.vcfin_thisparent.fasta

perl 3.1_get_reads_spanning_snps.pl ${2}_specific_filtered.vcf $3 $4 > snps_p2_not_in_p1.txt
# also produces reads_for_$2_specific_filtered.vcfin_otherparent.fasta
#       and reads_for_$2_specific_filtered.vcfin_thisparent.fasta

#remove them from vcf file


perl 3.2_remove_uncovered_snps.pl snps_p1_not_in_p2.txt ${1}_specific_filtered.vcf > ${1}_specific_filtered_coveredinboth.vcf

perl 3.2_remove_uncovered_snps.pl snps_p2_not_in_p1.txt ${2}_specific_filtered.vcf > ${2}_specific_filtered_coveredinboth.vcf

#validate and produce final output

perl 3.3_verify_snps_on_reference.pl $5 reads_for_${1}_specific_filtered.vcfin_thisparent.fasta reads_for_${1}_specific_filtered.vcfin_otherparent.fasta ${1}_FINAL.verfiy ${1}_FINAL.snps

perl 3.3_verify_snps_on_reference.pl $5 reads_for_${2}_specific_filtered.vcfin_thisparent.fasta reads_for_${2}_specific_filtered.vcfin_otherparent.fasta ${2}_FINAL.verify ${2}_FINAL.snps

#create a signle snpfile

perl 4_signlesnpfile.pl ${2}_FINAL.snps >> ${1}_FINAL.snps

mv $1_FINAL.snps final_distinguishing_snps_both_parents.txt