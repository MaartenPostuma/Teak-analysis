library(vcfR)
library(adegenet)
library(ggplot2)
library(ggdendro)
vcf<-read.vcfR("output/final.vcf")
sampleInfo<-read.csv("data/Teak_sample_info.csv")
Fis<-read.table("output/out.het",h=T)
Fis

genlight<-vcfR2genlight(vcf)
genlight<-genlight[-grep("DUP",indNames(genlight))]

# pca1<-dudi.pca(df = genlight, nf = 41, scannf = FALSE)

# dataPlot<-data.frame(sample=rownames(pca1$li),axis1=pca1$li[,1],axis2=pca1$li[,2],axis3=pca1$li[,3],axis4=pca1$li[,4])
# dataPlotFinal<-merge(sampleInfo,dataPlot,by="sample")
# axisPercentage<-round(pca1$eig/sum(pca1$eig)*100,2)
# 
# ggplot(dataPlotFinal,aes(x=axis1,y=axis2,label=sampleCorrect,col=REGION.of.ORIGIN))+geom_point()
# ggplot(dataPlotFinal,aes(x=axis1,y=axis4,label=sampleCorrect,col=REGION.of.ORIGIN))+geom_point()
# ggplot(dataPlotFinal,aes(x=axis3,y=axis4,label=sampleCorrect,col=REGION.of.ORIGIN))+geom_point()
# 
# genlight@pop
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
  scale_colour_discrete("")+
  ggsave("output/Figures/Tree.pdf",height=8,width=14)

ggplot(dend_data$segments)+
  geom_text(data = dend_data2, aes(y-7.5, x,col=metapop,label=COUNTRY.of.ORIGIN),size =5)+
  geom_segment(aes(x = y, y = x, xend = yend, yend = xend))+theme_dendro()+xlab("Genetic distance")+
  scale_colour_discrete("")#+
  #ggsave("output/Figures/TreeCountry.png",height=8,width=14)


basic.stats(genlight)


FisMerge<-merge(Fis,dend_data2,by.x="INDV",by.y="label")

FisMerge$grp<-"1"
FisMerge$grp[FisMerge$x>25]<-"2"


ggplot(FisMerge,aes(y=F,x=grp,fill=grp))+geom_boxplot()+
  scale_fill_brewer("",palette="Set3")+xlab("")+ylab("Fis")+theme_minimal()+theme(legend.position = "none",axis.text.x = element_blank())+
  ggsave("output/Figures/simpleFisPlot.png")



sampleInfo<-read.csv("data/Teak_sample_info.csv",stringsAsFactors = F)
sampleInfo<-sampleInfo[order(sampleInfo$sample),]
sampleInfo$ind<-c(3,1,2,4:length(sampleInfo$sample))


strucPlot<-data.frame()

for(i in 2:4){
  dataStructure<-read.table(paste("output/structure1/K=",i,"/MajorCluster/CLUMPP.files/ClumppIndFile.output",sep=""))
  dataStructure$K<-as.character(i)
  dataStructure$ind<-as.character(dataStructure$V1)
  structurePlot2<-merge(sampleInfo,dataStructure,by="ind")
  subStructure<-structurePlot2[,c(2,3,4,5,6,7,8,9,15:length(colnames(structurePlot2)))]
  strucPlot<-rbind(strucPlot,melt(subStructure))
}

strucPlot$KFact<-factor(strucPlot$K,levels = c(2,3,4),labels=c("K = 2","K = 3","K = 4"))

# 
# 

colnames(structurePlot2)
paste(strucPlot$ind)

test<-merge(dend_data2,strucPlot,by="sampleCorrect")
test$V1 <- factor(test$sampleCorrect, levels = unique(test$sampleCorrect)[order(unique(test$x))])


ggplot(test,aes(x=V1,y=value,fill=variable,width=1))+
  geom_bar(stat="identity")+coord_flip()+
  theme_minimal()+
  ylab("")+
  xlab("")+
  facet_grid(.~KFact,scales="free",space="free",switch="y")+
  ggtitle("A")+scale_fill_brewer("",palette = "Set3" )+
  ggsave("output/Figures/structureOutput.pdf")
  

Palettes
