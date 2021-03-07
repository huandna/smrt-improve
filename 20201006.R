rm(list=ls())
args=commandArgs(T)
cut_off=as.numeric(args[1])
wkd=args[3]
file1=args[2]
pre=paste0(file1,"_")
options(digits=3)
setwd(wkd)
#sort will detele NA
if_error <- function(x){
    cc <- sort(x)
    #p1 <- cc[round(length(cc)*0.975)-1]
    #p2 <- cc[round(length(cc)*0.025)+1]
    p1 <- cc[round(length(cc)*0.84)-1]
    p2 <- cc[round(length(cc)*0.16)+1]
    y <- (x > p1[1] | x < p2[1])
    return(y)}
error_rate <- function(z){
    if(sum(!is.na(z))==0){
        return(1)
    }else{
        return(sum(na.omit(z))/sum(!is.na(z))) 
    }
}
library(ggplot2)
#library(factoextra)
library(reshape)
library(pheatmap)
library(biclust)
#data <- readRDS("data_a.rds")
data <- read.table(file1,sep=" ",col.names=c("chr","pos","reads_id","ipd","pw"))
#saveRDS(data, "data_t.rds")
data2 <- melt(data,id.vars = c("pos","reads_id"),measure.vars = "ipd")
#data2$reads_id <- substring(data2$reads_id,61)
colnames(data2)[4] <- "IPD"
data <- data2
data_stat <- data.frame(id=data$reads_id[!duplicated(data$reads_id)],number=0)
rm(data2)
max_region=max(data$pos)
n=0
n_step=2000
n_window=5000
while (n<=max_region){
n <- n+n_step
print(n)
if(dim(data[(data$pos>=n-n_step)&(data$pos<n-n_step+n_window),])[1]==0 | length(unique(data[(data$pos>=n-n_step)&(data$pos<n-n_step+n_window),2])) <=3)
   next
data_t <- data[(data$pos>=n-n_step)&(data$pos<n-n_step+n_window),]
data3 <- cast(data_t,pos ~ reads_id)
rownames(data3) <- data3[,1]
data4 <- as.data.frame(t(apply(data3[,-1],1,if_error)))
colnames(data4) <- colnames(data3)[-1]
all_sum <- as.data.frame(apply(data4,2,error_rate))
all_sum[,2] <- colnames(data4)
colnames(all_sum) <- c("error_rate","reads_id")
ss <- all_sum[all_sum$error_rate >= cut_off,2]
data_stat[data_stat$id%in%ss,2] = data_stat[data_stat$id%in%ss,2]+1
}

delete_id <- data_stat[data_stat$number>=1,1]
final_delete <- paste0("",delete_id)
#final_delete <- delete_id
file_name <- paste0(paste0(pre,cut_off),".txt")
writeLines(final_delete,con=file_name,sep="\n")  













#mean(data[!data$reads_id%in%delete_id,]$IPD)
# p1<-ggplot(data_t,aes(x=pos,y=reads_id,fill=IPD))+ geom_raster()+ scale_fill_gradient2(low="red", high="darkgreen", mid="white") #填充不同的颜色
# p1
#ggplot(data=all_sum,mapping=aes(x=reads_id,y=error_rate,fill=error_rate))+geom_bar(stat="identity")+theme(axis.text.x=element_text(angle=90, hjust=1))
#max(all_sum$error_rate)
#ss <- all_sum[all_sum$error_rate >= 0.3,2]
#saveRDS(ss, "data_g1.rds")

# ggsave("CM008962.1_1005.pdf")
# 
# #聚类1
# set.seed(123)
# df <- as.data.frame(as.matrix(t(data3[,-1])))
# colnames(df)=rownames(data3)
# rownames(df)=colnames(data3[,-1])
# df[is.na(df)] <- 0
# fviz_nbclust(df, kmeans, method = "wss") + geom_vline(xintercept = 6, linetype = 2)
# km_result <- kmeans(df, 6, nstart = 40)
# fviz_cluster(km_result, data = df)
# #聚类2
# df <- as.data.frame(as.matrix(t(data4)))
# df[df==TRUE] <- 3
# df[df==FALSE] <- 2
# df[is.na(df)] <- 1
# fviz_nbclust(df, kmeans, method = "wss") + geom_vline(xintercept = 6, linetype = 2)
# set.seed(123)
# km_result <- kmeans(df, 6, nstart = 40)
# fviz_cluster(km_result, data = df)
#查看所聚类和错误率相关关系 
# all_sum2=cbind(all_sum,km_result$cluster)
# colnames(all_sum2)[3] <- "cluster_type"
# ggplot(all_sum2,aes(x=cluster_type, y=error_rate))+
# geom_point()
# geom_point(position="jitter")
# geom_point(position=position_jitter(width=.5, height=0))
# 双聚类
# aa <- BicatYeast
# library(biclust)
# drawHeatmap(aa)
# bb <- biclust(aa,method = BCQuest)
# s2=matrix(rnorm(5000),100,50)
# s2=as.matrix(data3)
# drawHeatmap(s2)
# set.seed(1)
# bics <- biclust(s2,BCPlaid(), back.fit = 2, shuffle = 3, fit.model =~m + a + b,iter.startup = 5, iter.layer = 30, verbose = TRUE)
# parallelCoordinates(x=s2,bicResult=bics,number=1, plotBoth=TRUE,plotcol=TRUE, compare=TRUE,info=TRUE,bothlab=c("hang","zong"), order =TRUE)
