rm(list=ls())

data<-read.table("c:/Users/postu003/Dropbox/Wageningen/TEAK/barcodes_teak.tsv",h=T)
data$Barcode_R1<-sub("$","C",data$Barcode_R1)
data$Barcode_R2<-sub("$","C",data$Barcode_R2)
write.table(data,"c:/Users/postu003/Dropbox/Wageningen/TEAK/barcodes_teak_final.tsv",quote=F,row.names = F,sep = "\t")

dataPop<-data.frame(sample=data$Sample,pop=sub("_.*$","",data$Sample))
write.table(dataPop,"c:/Users/postu003/Dropbox/Wageningen/TEAK/popmap_teak.tsv",
            quote=F,row.names = F,col.names = F,sep="\t")

