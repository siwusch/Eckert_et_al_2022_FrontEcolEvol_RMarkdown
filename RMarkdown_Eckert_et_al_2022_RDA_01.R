#' ---
#' title: <center><b>Markdown document from&colon;</b><br>Traces of Genetic but Not Epigenetic Adaptation in the Invasive Goldenrod _Solidago canadensis_ Despite the Absence of Population Structure</center>
#' pagetitle: RMarkdown document from:&nbsp;Eckert&nbsp;et&nbsp;al.&nbsp;(2022)
#' subtitle: <center>doi&colon; <a target="_blank" rel="noopener noreferrer" href="https://www.doi.org/10.3389/fevo.2022.856453">10.3389/fevo.2022.856453</a></center>
#' author: <center>Eckert, S., Herden, J., Stift, M., Durka, W., van Kleunen, M., & Joshi, J.</center>
#' date: <center>`r Sys.Date()`</center>
#' abstract: <p align="justify">This RMarkdown script belongs
#'   to a series of scripts generated by Silvia Eckert as part of
#'   the statistical analysis for the above-mentioned manuscript.
#'   The data underlying the applied R code can be found in the ZENODO
#'   repository and contains genetic (AFLP) and epigenetic (MSAP) markers
#'   from offspring of 25 _Solidago canadensis_ populations sampled along a
#'   latitudinal gradient in Central Europe. This particular RMarkdown script
#'   applies part 1/2 of RDA analaysis on both MSAP datasets. <b>Please cite this
#'   script as follows:</b></p><br><p>Eckert, S., Herden, J.,
#'   Stift, M., Durka, W., van Kleunen, M., & Joshi, J. (2022). Data From&colon;
#'   Traces of Genetic but Not Epigenetic Adaptation in the Invasive
#'   Goldenrod _Solidago canadensis_ Despite the Absence of Population
#'   Structure. _Zenodo_. doi&colon; <a target="_blank" rel="noopener noreferrer" href="https://www.doi.org/10.5281/zenodo.6388135">10.5281/zenodo.6388135</a></center></p>
#' geometry: margin=2cm
#' output:
#'   html_document:
#'      code_folding: show
#'      keep_md: FALSE
#'      theme: flatly
#'      highlight: textmate
#'      df_print: paged
#'      toc: true
#'      toc_float: true
#' ---
#' 

#'
#'```{r setup, include = FALSE}
#'knitr::opts_chunk$set(eval=FALSE, cache=FALSE, warning=FALSE)
#'```

#' # Packages
#' <a href="#top">Back to top</a>
#+ project_packages, results='hide', message=FALSE, warning=FALSE
########### packages ...................... ####
# install.packages("name_of_package") # install necessary packages
# install knitr to save this script as html output using RStudio with Ctrl+Shift+K (Windows & Linux) or Command+Shift+K (macOS)
# install.packages("knitr") 
# getwd() # get current working directory
# setwd() # set working directory
# create folder for datasets to be stored to get this RMarkdown script running
dir.create("./data",
           showWarnings=F)
# add necessary libraries
library(vegan)
library(psych)
library(ggplot2)
library(tibble)
library(plyr)
library(dplyr)

#' ## Functions
#' <a href="#top">Back to top</a>
#+ functions
########## functions ####
# As cited in the main manuscript, large parts of this script and the outliers() function were derived from
# Forester et al. (2018; doi: 10.1111/mec.14584) and their published step-by-step
# The guide, that was followed in this script, is published here: https://popgen.nescent.org/2018-03-27_RDA_GEA.html#references
# function from Forester et al. (2018) to check for outliers in RDA
outliers <- function(x,z){
  # x = Vector. Loadings names for each locus
  # z = Integer. The number of standard deviations to use as threshold for outlier detection
  lims <- mean(x)+c(-1,1)*z*sd(x) # find loadings +/-z sd from mean loading     
  x[x <lims[1]|x>lims[2]]  # locus names in these tails
  }

#' # Load data
#' <a href="#top">Back to top</a>
#+ project_load.data
########### load data ....................... ####
# load AFLP/MSAP data
source("RMarkdown_Eckert_et_al_2022_loadMolecularData.R")
# subset to control plants
# presence/absence data (@type: PA)
AFLP_C <- AFLP[AFLP$treatment=='CON',]; tibble(AFLP_C)

#' ## MSAP-n
#' <a href="#top">Back to top</a>
#+ project_load.MSAPn
######## MSAP-n ####
# subset to control plants
# presence/absence data (@type: PA)
MSAPn_C <- MSAPn[MSAPn$treatment=='CON',]; tibble(MSAPn_C)

#' ## MSAP-m
#' <a href="#top">Back to top</a>
#+ project_load.MSAPm
######## MSAP-m ####
# subset to control plants
# presence/absence data (@type: PA)
MSAPm_C <- MSAPm[MSAPm$treatment=='CON',]; tibble(MSAPm_C)

#' ## Environmental predictors
#' <a href="#top">Back to top</a>
#+ project_load.env
######## Predictors ####
ClimData <- tibble(read.table("./data/Data_MEMGENE_AFLP.txt",
                              header=T)); ClimData
colnames(ClimData)[5] <- "lat"
# expand value for each uniqueID
# AFLP
AFLP_env <- merge(AFLP_C[,c(1,5,7)],
                  ClimData,
                  by="lat"); tibble(AFLP_env)
# MSAP-m
MSAPm_env <- merge(MSAPm_C[,c(1,5,7)],
                    ClimData,
                    by="lat"); tibble(MSAPm_env)
# MSAP-n
MSAPn_env <- merge(MSAPn_C[,c(1,5,7)],
                    ClimData,
                    by="lat"); tibble(MSAPn_env)

#' # RDA
#' <a href="#top">Back to top</a>
#+ project_RDA
######## RDA ............................... ####
#' ## AFLP
#' <a href="#top">Back to top</a>
#+ project_RDA_AFLP
######## AFLP ####
# run RDA
set.seed(123)
AFLP_C.rda <- rda(AFLP_C[,-c(1:8)] ~ .,
                  data=AFLP_env[,4:6],
                  scale=F)
AFLP_C.rda
# adjusted R-squared
RsquareAdj(AFLP_C.rda)
# visualize results
summary(eigenvals(AFLP_C.rda,
                  model="constrained"))
screeplot(AFLP_C.rda)
# significance of full model
set.seed(123)
AFLP_C.signif.full <- anova.cca(AFLP_C.rda,
                                permutations=9999,
                                parallel=getOption("mc.cores")); AFLP_C.signif.full

#' ## MSAP-m
#' <a href="#top">Back to top</a>
#+ project_RDA_MSAPm
######## MSAP-m ####
# run RDA
set.seed(123)
MSAPm_C.rda <- rda(MSAPm_C[,-c(1:8)] ~ .,
                    data=MSAPm_env[,4:6],
                    scale=F)
MSAPm_C.rda
# adjusted R-squared
RsquareAdj(MSAPm_C.rda)
# visualize results
summary(eigenvals(MSAPm_C.rda,
                  model="constrained"))
screeplot(MSAPm_C.rda)
# significance of full model
set.seed(123)
MSAPm_C.signif.full <- anova.cca(MSAPm_C.rda,
                                  permutations=9999,
                                  parallel=getOption("mc.cores")); MSAPm_C.signif.full
# significant axes via broken-stick criterion
MSAPm_C.rdasig <- BiodiversityR::PCAsignificance(MSAPm_C.rda,
                                                  axes=3); MSAPm_C.rdasig
# plot axes and broken-stick criterion
barplot(MSAPm_C.rdasig[c('percentage of variance',
                          'broken-stick percentage'),],
        beside=T,
        xlab='PCA axis',
        ylab='explained variation [%]',
        col=c('grey',
                'black'),
        legend=TRUE)
# number of axes that are significant according to the broken-stick criterion
MSAPm_C.n.rda <- as.numeric(table((MSAPm_C.rdasig['% > bs%',])==1)); MSAPm_C.n.rda
# outliers
MSAPm_load.rda <- scores(MSAPm_C.rda,
                          choices=c(1:MSAPm_C.n.rda),
                          display="species"); MSAPm_load.rda
# find outlier loci and
# create a object containing data frames with columns "axis", "locus", "loading",
MSAPm_outlierList <- vector(mode="list"); MSAPm_outlierList
for(i in 1:MSAPm_C.n.rda) {
  outlier_n <- outliers(MSAPm_load.rda[,i],3)
  MSAPm_outlierList[[paste0("cand",
        (length(MSAPm_outlierList)+1))]] <- cbind.data.frame(axis=rep(i,
                imes=length(outlier_n)),
                locus=names(outlier_n),
                loading=unname(outlier_n))}; MSAPm_outlierList
# turn list into combined data.frame
MSAPm_outlier_df <- plyr::ldply(MSAPm_outlierList,
                                data.frame)
colnames(MSAPm_outlier_df)[1] <- "ID"; tibble(MSAPm_outlier_df)
# add predictors MEMGENE1, MEMGENE2, MEMGENE3
MSAPm_preds <- matrix(nrow=dim(MSAPm_outlier_df)[1],
                       ncol=3) # 3 columns for 3 predictors
colnames(MSAPm_preds) <- c("MEMGENE1","MEMGENE2","MEMGENE3"); tibble(MSAPm_preds)
#  add correlation of each locus with each of the predictor variables
for (i in 1:length(MSAPm_outlier_df$locus)) {
  id <- MSAPm_outlier_df[i,2]
  loc_vec <- dplyr::select(MSAPm_C[,-c(1:8)],
                           all_of(id))[,1]
  MSAPm_preds[i,] <- apply(MSAPm_env[,4:6],2,function(x) cor(x,loc_vec))}
MSAPm_preds <- data.frame(MSAPm_preds)
MSAPm_preds$locus <- MSAPm_outlier_df$locus
MSAPm_C.candidates <- merge(MSAPm_outlier_df,
                             MSAPm_preds,
                             by="locus"); tibble(MSAPm_C.candidates)
# add most significant predictor
for (i in 1:length(MSAPm_C.candidates$locus)){
  loc_row <- MSAPm_C.candidates[i,]
  MSAPm_C.candidates[i,8] <- names(which.max(abs(loc_row[5:7]))) # gives the variable
  MSAPm_C.candidates[i,9] <- max(abs(loc_row[5:7]))} # gives the correlation
# rename
colnames(MSAPm_C.candidates)[8] <- "predictor"
colnames(MSAPm_C.candidates)[9] <- "correlation"
table(MSAPm_C.candidates$predictor)
# save
write.table(MSAPm_C.candidates,
            file="./data/Data_RDA_MSAPm_outliers.txt",
            row.names=F)
# calculate percentage of explained variation
MSAPm_rdasum <- summary(MSAPm_C.rda)
MSAPm_rdasum$cont # Prints the "Importance of components" table
MSAPm_rdasum$cont$importance[2,"RDA1"]
MSAPm_rdasum$cont$importance[2,"RDA2"]
MSAPm_rdasum$cont$importance[2,"RDA3"]

#' ## MSAP-n
#' <a href="#top">Back to top</a>
#+ project_RDA_MSAPn
######## MSAPn ####
# run RDA
set.seed(123)
MSAPn_C.rda <- rda(MSAPn_C[,-c(1:8)] ~ .,
                    data=MSAPn_env[,4:6],
                    scale=F)
MSAPn_C.rda
# adjusted R-squared
RsquareAdj(MSAPn_C.rda)
# visualize results
summary(eigenvals(MSAPn_C.rda,
                  model="constrained"))
screeplot(MSAPn_C.rda)
# significance of full model
set.seed(123)
MSAPn_C.signif.full <- anova.cca(MSAPn_C.rda,
                                  permutations=9999,
                                  parallel=getOption("mc.cores")); MSAPn_C.signif.full
# significant axes
MSAPn_C.rdasig <- BiodiversityR::PCAsignificance(MSAPn_C.rda,
                                                  axes=3); MSAPn_C.rdasig
barplot(MSAPn_C.rdasig[c('percentage of variance',
                          'broken-stick percentage'),],
        beside=T,
        xlab='PCA axis',
        ylab='explained variation [%]',
        col=c('grey','black'),
        legend=TRUE)
# number of axes that are significant according to the broken-stick criterion
MSAPn_C.n.rda <- as.numeric(table((MSAPn_C.rdasig['% > bs%',])==1)); MSAPn_C.n.rda
# outliers
MSAPn_load.rda <- scores(MSAPn_C.rda,
                          choices=c(1:MSAPn_C.n.rda),
                          display="species"); MSAPn_load.rda
# find outlier loci and
# creata a list object with data frames and columns "axis", "locus", "loading",
MSAPn_outlierList <- vector(mode="list"); MSAPn_outlierList
for(i in 1:MSAPn_C.n.rda) {
  outlier_n <- outliers(MSAPn_load.rda[,i],3)
  MSAPn_outlierList[[paste0("cand",
            (length(MSAPn_outlierList)+1))]] <- cbind.data.frame(axis=rep(i,
                            times=length(outlier_n)),
                            locus=names(outlier_n),
                            loading=unname(outlier_n))}; MSAPn_outlierList
MSAPn_outlier_df <- plyr::ldply(MSAPn_outlierList,data.frame)
colnames(MSAPn_outlier_df)[1] <- "ID"; tibble(MSAPn_outlier_df)

# add predictors MEMGENE1, MEMGENE2, MEMGENE3
MSAPn_preds <- matrix(nrow=dim(MSAPn_outlier_df)[1],
                       ncol=3) # 3 columns for 3 predictors
colnames(MSAPn_preds) <- c("MEMGENE1","MEMGENE2","MEMGENE3"); tibble(MSAPn_preds)
#  add correlation of each locus with each of the predictor variables
for (i in 1:length(MSAPn_outlier_df$locus)) {
  id <- MSAPn_outlier_df[i,2]
  loc_vec <- dplyr::select(MSAPn_C[,-c(1:8)],all_of(id))[,1]
  MSAPn_preds[i,] <- apply(MSAPn_env[,4:6],2,function(x) cor(x,loc_vec))}
MSAPn_preds <- data.frame(MSAPn_preds)
MSAPn_preds$locus <- MSAPn_outlier_df$locus
MSAPn_C.candidates <- merge(MSAPn_outlier_df,MSAPn_preds,
                             by="locus"); tibble(MSAPn_C.candidates)
# add most significant predictor
for (i in 1:length(MSAPn_C.candidates$locus)) {
  loc_row <- MSAPn_C.candidates[i,]
  MSAPn_C.candidates[i,8] <- names(which.max(abs(loc_row[5:7]))) # gives the variable
  MSAPn_C.candidates[i,9] <- max(abs(loc_row[5:7]))} # gives the correlation
# rename
colnames(MSAPn_C.candidates)[8] <- "predictor"
colnames(MSAPn_C.candidates)[9] <- "correlation"
table(MSAPn_C.candidates$predictor) 
# save
write.table(MSAPn_C.candidates,
            file="./data/Data_RDA_MSAPn_outliers.txt",
            row.names=F)
# calculate percentage of explained variation
MSAPn_rdasum <- summary(MSAPn_C.rda)
MSAPn_rdasum$cont # Prints the "Importance of components" table
MSAPn_rdasum$cont$importance[2,"RDA1"]
MSAPn_rdasum$cont$importance[2,"RDA2"]
MSAPn_rdasum$cont$importance[2,"RDA3"]

#' # Session info
#' <a href="#top">Back to top</a>
#+ Session.info
sessionInfo()
#' <a href="#top">Back to top</a>
######## Session info .................. ####