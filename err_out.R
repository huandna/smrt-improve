rm(list=ls())
args=commandArgs(T)
wkd=args[2]
file1=args[1]
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
        return(c(0,0,2))
    }else{
        err1 <- sum(na.omit(z))
        err2 <- sum(!is.na(z))
        err3 <- round(err1/err2,3)
        return(c(err1,err2,err3))
    }
}
library(ggplot2)
library(reshape)
library(pheatmap)
library(biclust)
data_raw <- read.table(file1,sep=" ",col.names=c("chr","pos","reads_id","ipd","pw"))
aa <- data.frame(true_value=0,no_na=0,error_rate=0,reads_id="test")
aa <- aa[-1,]
for (chr in unique(as.character(data_raw[,1])))
{
data2 <- melt(data_raw[data_raw[,1]==chr,],id.vars = c("pos","reads_id"),measure.vars = "ipd")
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
all_sum[4,] <- colnames(data4)
all_sum <- as.data.frame(t(all_sum))
colnames(all_sum) <- c("true_value","no_na","error_rate","reads_id")
all_sum[,1] <- as.numeric(as.character(all_sum[,1]))
all_sum[,2] <- as.numeric(as.character(all_sum[,2]))
all_sum[,3] <- as.numeric(as.character(all_sum[,3]))
all_sum[,4] <- as.character(all_sum[,4])
rownames(all_sum) <- c(1:dim(all_sum)[1])
aa <- rbind(aa,all_sum)
}
}
file_name <- paste0(pre,"_error.csv")
write.csv2(aa,file = file_name,row.names = FALSE, quote = FALSE)

