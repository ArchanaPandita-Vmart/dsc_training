# Date: 29JUN2020 Time: 10:00AM
# Author: Data Transformation (Archana Pandita)

# Objective: Campaign Preparation
#-- 

#----Cleaning Enviornment----
cat("\n\n")
cat("Cleaning enviornment","\n")
rm(list=ls()) 
gc()

#----Sourcing Libraries and external files----
# loading libraries
cat("\n\n")
cat("Loading libraries","\n")
library(dplyr)
library(data.table)
library(pbapply)
library(tidyr)
library(readxl)
library(arrow)

# sourcing external file
cat("\n\n")
cat("Sourcing external files","\n")

path_proj <- "D:/dsc_training"
path_lib <- file.path(path_proj) 

#----Path declarations----  
path_rfm <- file.path(path_proj,"input/rfm/24APR2021-24APR2021_CUSTOMER_RFM.parquet")
path_mt_str <- file.path(path_proj,"input/masters/store-master/mstr_store.csv")
path_mt_dlr <- file.path(path_proj,"/input/masters/delivery-master/delivery_master.csv")
path_output <- file.path(path_proj,"output/master_table.csv")
path_op <- file.path(path_proj,"output")

#----Local functions----

#data: starts with dt_
#master: starts with mt_

#sale/transactions: txn
#inventory: invt
#rfm: rfm
#delivery: 

#----Function Calls, Data reading & Manipulations----

#1.group customers into a,l,o & p  based on their recency as follows:(column: customer_type) 
#a: 0 <= recency <= 180, l: 181<= recency <= 360, o: 361<= recency <= 720 & p: recency >720 Where recency = today - customer’s last transaction date
#a: active, l: lapsers, o: old, p: preold

dt_rfm <- read_parquet(path_rfm, as_tibble = TRUE)
dt_rfm$lastdate <- sample(seq(as.Date('01JAN2020', "%d%b%Y"), as.Date('26JUN2020',"%d%b%Y"), by="day"), 6040,replace=TRUE)
dt_rfm$recency <- as.numeric(Sys.Date()-dt_rfm$lastdate)
dt_rfm$customer_type <- cut(dt_rfm$recency, breaks=c(0,180,360,720,Inf), labels = c('a','l','o','p'))
 
#2. map store with their zone, region & language using store_master & language_master

mt_str <- fread(path_mt_str, integer64 = "double") 
 
#3. map customers with their communication_medium using delivery_master    n_a: not_available    d: delivered   n_d: not_delivered If customer is not present in delivery_master then n_a

dt_rfm <- left_join(dt_rfm, mt_str,by="Store")
mt_dlr <- fread(path_mt_dlr)

dt_rfm$Customer_Mobile <- as.numeric(dt_rfm$Customer_Mobile)
mt_dlr$Customer_Mobile <- as.numeric(mt_dlr$Customer_Mobile)

dt_rfm <- left_join(dt_rfm,mt_dlr,by="Customer_Mobile")

dt_rfm$Communication_Medium <- ifelse(is.na(dt_rfm$Communication_Medium), 'n_a',dt_rfm$Communication_Medium )
 
#4. add a column ‘test_control’ with two randomly generated values ‘c’ & ‘t’ with respective probabilities of 0.05 & 0.95 
#e.g. for 1000 customers ‘c’ will occur for approx 50(1000 * 0.05) times & ‘t’ will occur for approx 950(1000 * 0.95)

dt_rfm$test_control <- sample(c('t','c'),nrow(dt_rfm),replace = TRUE,prob=c(0.95,0.05))
dt_rfm <- dt_rfm[, c("Customer_Mobile","Store","Zone","Region","Language","customer_type","Communication_Medium","test_control")]

#5. save above table as ‘master_table.csv’

fwrite(dt_rfm,path_output)

#6. create individual folder for each of the region with its customers details from master_table & saved in csv format
dt_rfm <- fread(path_output) 

setwd(path_op)
dt_rfm$Region[is.na(dt_rfm$Region)] <-  "others"

for(r in unique(dt_rfm$Region)) {
  region_data <- dt_rfm[dt_rfm$Region %in% r, ]
  if (!dir.exists(r)) {
    dir.create(r, recursive = TRUE)}
  write.csv(region_data, file.path(r, paste0(r,".csv")), row.names = FALSE)
}

 
