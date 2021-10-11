---
title: "EBB analysis data prep"
output: html_notebook
editor_options: 
  chunk_output_type: inline
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
library(easypackages)
libraries("readxl","ggplot2","stringr", "rlist", "data.table", "DBI", "RSQLite",  
          "stargazer", "Hmisc","magrittr","formattable", "RPostgreSQL", "dplyr", 
          "tidyverse", "dbplyr")
options(scipen=999)

```

This is all of the backend code for this paper. 

# Create a database

First and foremost, we need to set up a database. Form 477 data is simply too big to work with in memory, even the Dec 2019 csv in 70 million+ lines long, including both commercial and residential services. So I created a simple SQLite database using DB Browser for SQlite called form477 in the same folder as all of the data. Let's connect to the database.   

```{r }

form477 <- DBI::dbConnect(RPostgres::Postgres(),
                      dbname = "postgres",
                      host = "localhost", port = 5432,
                      user = "postgres", 
                      password = rstudioapi::askForPassword("Database password"))

src_dbi(form477)

```

Next, let's load the most recent Form 477 data from December of 2019. [All Form 477 data is here](https://www.fcc.gov/general/broadband-deployment-data-fcc-form-477). I have found in previous projects that fread is the quickest csv read function for large files, so let's stick with what works.

```{r }

EBB_Enrollment_10_1_zip5


dec2019 <- fread("fbd_us_with_satellite_dec2019_v1.csv", header = T, 
                 colClasses=c("BlockCode"="character", "MaxAdDown"="numeric", 
                              "Consumer"="numeric", "LogRecNo"="NULL", 
                              "FRN"="NULL", "DBAName"="NULL", 
                              "HoldingCompanyName"="NULL", "HocoNum"="NULL", 
                              "HocoFinal"="NULL", "Business"="NULL", 
                              "MaxCIRDown"="NULL", "MaxCIRUp"="NULL", 
                              "ProviderName"="NULL", "StateAbbr"="NULL")) %>%
  filter(Consumer == 1) %>%
  mutate(BlockGroupCode = substr(BlockCode, 1, 12)) %>%
  mutate(Tract = substr(BlockCode, 1, 11)) %>%
  mutate(FIPS = substr(BlockGroupCode, 1, 5)) 

```

Let's write this table into the database.

```{r }

dbWriteTable(form477, "dec2019", value = dec2019, overwrite = TRUE, row.names = FALSE)

