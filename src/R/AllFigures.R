library(vcfR)
library(adegenet)
library(ggplot2)
library(ggdendro)
vcf<-read.vcfR("output/filter8_10.recode.vcf")
sampleInfo<-read.csv("data/Teak_sample_info.csv")
Fis<-read.table("output/out.het",h=T)
Fis

genlight<-vcfR2genlight(vcf)
genlight<-genlight[-grep("DUP",indNames(genlight))]

pca1<-dudi.pca(df = genlight, nf = 41, scannf = FALSE)

dataPlot<-data.frame(sample=rownames(pca1$li),axis1=pca1$li[,1],axis2=pca1$li[,2],axis3=pca1$li[,3],axis4=pca1$li[,4])
dataPlotFinal<-merge(sampleInfo,dataPlot,by="sample")
axisPercentage<-round(pca1$eig/sum(pca1$eig)*100,2)

ggplot(dataPlotFinal,aes(x=axis1,y=axis2,label=sampleCorrect,col=REGION.of.ORIGIN))+geom_point()
ggplot(dataPlotFinal,aes(x=axis1,y=axis4,label=sampleCorrect,col=REGION.of.ORIGIN))+geom_point()
ggplot(dataPlotFinal,aes(x=axis3,y=axis4,label=sampleCorrect,col=REGION.of.ORIGIN))+geom_point()

genlight@pop
clusters<-find.clusters(genlight,n.pca=40,max.n.clust = 10,n.clust = 7)

dist<-dist(genlight)
clustering<-hclust(dist,method = "complete")
dend_data<-dendro_data(clustering)


dend_data$labels$col<-as.character(sub('_[^_]*$', '', dend_data$labels$label))
dend_data$labels$pop<-dend_data$labels$col
dend_data2<-merge(dend_data$labels,sampleInfo,by.x="label",by.y="sample",sort = F)


dend_data2
ggplot(dend_data$segments)+
  geom_text(data = dend_data2, aes(y-7.5, x,col=metapop,label=sampleCorrect),size =5)+
  geom_segment(aes(x = y, y = x, xend = yend, yend = xend))+theme_dendro()+xlab("Genetic distance")+
  scale_colour_discrete("")#+
  #ggsave("output/Figures/Tree.png",height=8,width=14)

ggplot(dend_data$segments)+
  geom_text(data = dend_data2, aes(y-7.5, x,col=metapop,label=COUNTRY.of.ORIGIN),size =5)+
  geom_segment(aes(x = y, y = x, xend = yend, yend = xend))+theme_dendro()+xlab("Genetic distance")+
  scale_colour_discrete("")#+
  #ggsave("output/Figures/TreeCountry.png",height=8,width=14)


basic.stats(genlight)


FisMerge<-merge(Fis,dend_data2,by.x="INDV",by.y="label")

FisMerge$grp<-"1"
FisMerge$grp[FisMerge$x>25]<-"2"


ggplot(FisMerge,aes(y=F,x=grp,fill=grp))+geom_boxplot()+geom_point(aes(col=metapop),size=2)+
  ggsave("output/Figures/simpleFisPlot.png")
