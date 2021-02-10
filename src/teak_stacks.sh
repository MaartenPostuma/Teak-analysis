wget https:://wherever/the/reads/are/stored

conda env create -f src/env/teak.yaml

#Run clone filter
clone_filter -1 rawReads/Run_4_various_FKDL202561777-1a_H7MCMCCX2_L2_1.fq.gz \ 
-2 rawReads/Run_4_various_FKDL202561777-1a_H7MCMCCX2_L2_2.fq.gz -P \
-o output/demulti/ \
--oligo_len_1 3 --oligo_len_2 3 \
--inline_inline -i gzfastq

#Run demultiplexing using barcode file in the data file
process_radtags -1 output_demulti/Run_4_various_FKDL202561777-1a_H7MCMCCX2_L2_1.1.fq.gz -o output/demulti/ \ 
-2 output/demulti/Run_4_various_FKDL202561777-1a_H7MCMCCX2_L2_2.2.fq.gz \
-b data/barcodes_teak_final.tsv \
--barcode_dist_2 0 \
--renz_1 NsiI --renz_2 AseI \
--retain_header --inline_inline
#Run tests with different parameter m
for i in {2..6}:
do mkdir output_stacks/m$i
denovo_map.pl --samples output/demulti/ --popmap data/popmap_teak.tsv -T 1 \
-o output_stacks/m$i -m $i \
-X "populations: --vcf -r 80" \
& done

#Run test with different parameters M
for i in {2..6}:
do mkdir output_stacks/m$i
denovo_map.pl --samples output/demulti/ --popmap data/popmap_teak.tsv -T 1 \
-o output_stacks/m$i -M $i -m 3 -n $i \
-X "populations: --vcf -r 80" \
& done

#Run the final selected parameter combination
denovo_map.pl --samples output/demulti/ --popmap data/popmap_teak.tsv -T 4 -o output/final -M 5 -m 3 -n 5 -X populations: --vcf

#Run the SNPFilterReport to explore effects of different filtering parameters
snakemake -j 12 --use-conda -s src/SNPFilterReport/
mv src/SNPFilterReport/report.html output/reportFilteringTeak.html

mv SNPFilterReport/vcf/filter8/filter8_1.recode.vcf output/final.vcf
#Run vcftools to determine heterozygosity / Fis values for all individuals in the population
vcftools --vcf output/final.vcf --het --out output/Fis

#Make whitelist of 1000 SNPs for structure analysis. Or use the whitelist included in the data directory (this includes the same markers used in the paper)
#grep -v "^#" output/final.vcf |
#cut -f 1,2 |
#sort |
#uniq |
#shuf |
#head -n 1000 |
#sort -n > data/whitelist.tsv

vcftools --vcf output/final.vcf --out data/1000 --recode --positions data/whitelist.tsv

populations -V output/1000.recode.vcf --popmap data/popmap_teak_nodupes.tsv --structure  --write-single-snp -W data/whitelist.tsv --out-path output/

R
data<-read.table("data/1000.recode.p.structure",h=T)
data$pop<-as.numeric(data$pop)
data$ID<-as.numeric(data$ID)

write.table(data,"data/structureInFinal",quote=F,row.names=F,sep="\t")
write.table(data[,c(1,2)],"popCoding")
q()



snakemake -j {number of threads}

Make output compatible with structure selector 
cd resultsfile.
for dir in *; do  for file in $dir/* ; do   mv $file ${file}_${dir}_f; done; done
zip -r Results*
cat ../../structureIn | cut -f1,2 | tail -n +3 | uniq > popmapStructure

go to https://lmme.ac.cn/StructureSelector/
upload zip file + popfile
Check ordering of pops etc.




