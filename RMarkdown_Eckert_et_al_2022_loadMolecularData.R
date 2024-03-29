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
#'   loads AFLP and MSAP raw scoring data. <b>Please cite this
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
library(tibble)
library(tidyverse)
# devtools::install_github("inbo/inborutils")
library(inborutils)

#' # Load data
#' <a href="#top">Back to top</a>
#+ project_load.data
########### Load data ...................... ####
# PREMISE: for this script to work, the corresponding data needs to be downloaded
# from the Zenodo repository and saved in a separate folder
download_zenodo(doi="10.5281/zenodo.6388135",
                path = "./data/",
                quiet=FALSE)

#' ## AFLP
#' <a href="#top">Back to top</a> 
#+ project_load.AFLP
######## AFLP ####
AFLP_raw <- read_table("./data/EckertHerdenStiftDurkavanKleunenJoshi_2022_FrontEcolEvol_AFLP_scoring_data.txt",
                       col_types=cols(uniqueID="c",
                                      common_garden_block="f",
                                      block_position="f",
                                      treatment=col_factor(levels=c("CON","ZEB"),
                                                           ordered=T),
                                      lat="d",
                                      lon="d",
                                      populationID="f",
                                      maternal_line="f",
                                      .default=col_integer()))
# rename markers to avoid warning and errors in later analyses
AFLP <- dplyr::rename_with(AFLP_raw,~gsub(".","_",.x,
                                          fixed=T))
names(AFLP) # check marker names
# check data and classes
dim(AFLP); AFLP

#' ## MSAP-n
#' <a href="#top">Back to top</a>
#+ project_load.MSAPn
######## MSAP-n ####
MSAP_raw <- read_table("./data/EckertHerdenStiftDurkavanKleunenJoshi_2022_FrontEcolEvol_MSAP_scoring_data_mix1.txt",
                       col_types=cols(populationID="c",
                                      sampleID="c",
                                      .default=col_integer()))
# rename "sampleID" to "uniqueID" to merge tables
colnames(MSAP_raw)[2]; colnames(MSAP_raw)[2] <- "uniqueID"
dim(MSAP_raw); MSAP_raw
# add metadata
meta <- read_table("./data/EckertHerdenStiftDurkavanKleunenJoshi_2022_FrontEcolEvol_AFLPMSAP_meta_data.txt",
                   col_types=cols(uniqueID="c",
                                  common_garden_block="f",
                                  block_position="f",
                                  treatment="f",
                                  lat="f",
                                  lon="f",
                                  populationID="f",
                                  maternal_line="f")); dim(meta); meta
# combine
MSAP <- right_join(meta,MSAP_raw[,-1],by="uniqueID")
# rename markers to avoid warning and errors in later analyses
MSAP <- dplyr::rename_with(MSAP,~gsub(".","_",.x,fixed=T))
# subset to non-methylated loci
MSAPn <- tibble(data.frame(MSAP[,c(1:8)],
                     MSAP[,grepl("uF|uV|uN|uP",
                                 names(MSAP))]))
names(MSAPn) # check marker names
# rename markers to avoid warning and errors in later analyses
MSAPn <- dplyr::rename_with(MSAPn,~gsub(".","_",.x,
                                        fixed=T))
# check data and classes
dim(MSAPn); MSAPn

#' ## MSAP-m
#' <a href="#top">Back to top</a>
#+ project_load.MSAPm
######## MSAP-m ####
# subset to non-methylated loci
MSAPm <- tibble(data.frame(MSAP[,c(1:8)],
                     MSAP[,grepl("MF|MV|MN|MP",
                                 names(MSAP))]))
names(MSAPm) # check marker names
# check data and classes
dim(MSAPm); MSAPm

#' # Session info
#' <a href="#top">Back to top</a>
#+ Session.info
sessionInfo()
#' <a href="#top">Back to top</a>
######## Session info .................. ####