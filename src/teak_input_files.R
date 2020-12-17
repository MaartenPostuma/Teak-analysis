rm(list=ls())

data<-read.table("c:/Users/postu003/Dropbox/Wageningen/TEAK/barcodes_teak.tsv",h=T)
data$Barcode_R1<-sub("$","C",data$Barcode_R1)
data$Barcode_R2<-sub("$","C",data$Barcode_R2)
write.table(data,"c:/Users/postu003/Dropbox/Wageningen/TEAK/barcodes_teak_final.tsv",quote=F,row.names = F,sep = "\t")

dataPop<-data.frame(sample=data$Sample,pop=sub("_.*$","",data$Sample))
write.table(dataPop,"c:/Users/postu003/Dropbox/Wageningen/TEAK/popmap_teak.tsv",
            quote=F,row.names = F,col.names = F,sep="\t")

ggplot(bismVsTruth,aes(x=fracBism,y=fracTrue))+geom_point(alpha=0.05)+xlab("Fraction methylation Bismark")+ylab("Fraction methylation truth")+facet_grid(.~context)+ggtitle("Bismark vs Truth pooled")+
  stat_poly_eq(formula = my.formula, 
               aes(label = paste(..rr.label..,sep="~",parse=T)),col="blue", 
               parse = TRUE)
