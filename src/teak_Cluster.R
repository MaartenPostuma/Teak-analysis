rm(list=ls())
library(vcfR)
library("SNPRelate")
library("ggplot2")
library("ggdendro")
library("reshape2")

countPopPerMetaPop<-function(x){
  return(length(unique(x)))
}


vcf.fn<-"final.vcf.recode.vcf"
image<-"images/mds.png"
popmap<-read.csv("Teak-analysis/data/Teak_sample_info.csv",h=T)
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


snpgdsVCF2GDS(vcf.fn, sub("vcf$","gds$",vcf.fn), method=c("biallelic.only"),verbose = TRUE)
genofile <- snpgdsOpen(sub("vcf$","gds$",vcf.fn))

diss<-snpgdsDiss(genofile)
hc<-snpgdsHCluster(diss)
  
fit <- hclust(as.dist(hc$dist), method="ward.D") 
dend_data <- dendro_data(fit, type = "rectangle")
dend_data$labels$col<-as.character(sub('_[^_]*$', '', dend_data$labels$label))
dend_data$labels$pop<-dend_data$labels$col
dend_data2<-merge(dend_data$labels,popmap,by="pop",sort = F)
  
  
ggplot(dend_data$segments)+
  geom_text(data = dend_data2, aes(x, y,col=metaPop,label=ID),size =5)+
  geom_segment(aes(x = x, y = y, xend = xend, yend = yend))+theme_light()+xlab("")+ylab("genetic distance")
        

