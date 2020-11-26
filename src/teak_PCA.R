rm(list=ls())
library(vcfR)
library(adegenet)
library(ggplot2)

countPopPerMetaPop<-function(x){
  return(length(unique(x)))
}

setwd("C:/Users/postu003/Dropbox/Wageningen/knikkend")

vcf.fn<-"data/filter5_0.8.recode.vcf"
popmap<-read.table("data/popmap.tsv",h=F)
colnames(popmap)<-c("ID","pop")
popmap$metapop<-"test"
popmap$metaPop<-popmap$metapop


popPerMeta<-aggregate(pop~metaPop,popmap,countPopPerMetaPop)
cols<-rainbow(length(popPerMeta$metaPop))
shapes<-c(15:(15+max(popPerMeta$pop)))


for(i in 1:length(unique(popmap$metaPop))){
  popmap$col[popmap$metaPop==unique(popmap$metaPop)[i]]<-cols[i]
  for(j in  1:length(popmap$col[popmap$metaPop==unique(popmap$metaPop)[i]])){
    popmap$shape[popmap$metaPop==unique(popmap$metaPop)[i]][j]<-shapes[j]
    
  }
}
popmap$order<-paste(popmap$metaPop,popmap$pop)
popmap<-popmap[order(popmap$order),]

vcf<-read.vcfR(vcf.fn)
genlight<-vcfR2genlight(vcf)


pca<-glPca(genlight,nf = 10)



pcaPlot <- data.frame(pca$scores,sample=row.names(pca$scores),pop=sub("_.*$","",row.names(pca$scores)),ID=row.names(pca$scores))

plotFinal<-merge(pcaPlot,popmap,by="ID")


ggplot(plotFinal,aes(x=PC1,y=PC2,col=metaPop,label=ID))+theme_light()+
  xlab("PCA 1")+ylab("PCA 2")+geom_text()
