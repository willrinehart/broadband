---
title: "Regression analysis data prep"
output: html_notebook

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

dec2019 <- fread("/Volumes/Tooth/Documents/Data Sets/CGO FCC broadband analysis/data/fbd_us_with_satellite_dec2019_v1.csv", header = T, 
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

```

Just to make sure, let's check our work.

```{r }

src_dbi(form477)

```

Sure looks like the dec2019 table is in the database to me. So let's drop the dec2019 variable from our environment. 

```{r }

rm(dec2019)

```

I know this is convoluted, but we need to go back and create a new variable name based on that Dec 2019 table in the database, so we can query it directly. Let's do that now. 

```{r}

dec2019 <- tbl(form477, "dec2019")

```

Let's add in population estimates from the FCC, which can be found [here](https://www.fcc.gov/staff-block-estimates).

```{r }

pop2019 <- fread("/Volumes/Tooth/Documents/Data Sets/CGO FCC broadband analysis/data/us2019.csv", header = T,
                 colClasses=c("block_fips"="character")) %>%
  select(block_fips, hu2019, hh2019, pop2019)
  

dbWriteTable(form477, "pop2019", value = pop2019, overwrite = TRUE, row.names = FALSE)

rm(pop2019)

pop2019 <- tbl(form477, "pop2019")

```

What's great about the R and SQLite setup is that R will do all of the intepretation for you, so you can run regression models within R using the database. So next, let's join Dec 2019 Form 477 data with population data. 

```{r }

dec2019 <- dec2019 %>%
  left_join(., pop2019, by = c("BlockCode" = "block_fips"))

```

Before moving on to some analysis, how many records are there?

```{r }

dec2019 %>%  
  summarise(n = count(Provider_Id))

```

About 60 million rows. Looking at some other of my code, I know that the dbl class is going to give me trouble. I much prefer numeric. 

```{r }

dec2019 <- dec2019 %>% 
  mutate(hu2019=as.numeric(hu2019), pop2019=as.numeric(pop2019), hh2019=as.numeric(hh2019),
         MaxAdDown=as.numeric(MaxAdDown), MaxAdUp=as.numeric(MaxAdUp))

```

### Analysis of December 2019 data

I'm greedy and excited. Let's get into this and do a little digging before we create the rest of the database.

What's the population for December 2019 data, you think?

```{r }

filter(dec2019) %>%
  group_by(BlockCode) %>%
  summarise(max_pop = max(pop2019, na.rm = TRUE)) %>%
  summarise(sum = sum(max_pop, na.rm = TRUE))

```

So, the total population by this estimate is 331,775,907 (331775907). Just to explain my methods here, I want to data to be readable, hence the reason for commas, but I also want to have easy access to the integer for use, hence the parenthetical. 	

What about households?

```{r }

filter(dec2019) %>%
  group_by(BlockCode) %>%
  summarise(max_pop = max(hh2019, na.rm = TRUE)) %>%
  summarise(sum = sum(max_pop, na.rm = TRUE))

```

That's a total of 125,186,308 (125186308) households.

Ok, now let's do something more complex. What is the total population with service more than or equal to 25/3?

```{r }

dec2019 %>%
  group_by(BlockCode) %>%
  filter(MaxAdDown>=25 & MaxAdUp>=3, !(TechCode == "60")) %>%
  summarise(max_pop = max(pop2019, na.rm = TRUE)) %>%
  summarise(sum = sum(max_pop))

```

The total population by this estimate is 317,257,033 (317257033). By this estimate then, around 14.5 million people don't have access to Internet service. 

And about how many households have service more than or equal to 25/3?

```{r }

filter(dec2019) %>%
  filter(MaxAdDown>=25 & MaxAdUp>=3, !(TechCode == "60")) %>%
  group_by(BlockCode) %>%
  summarise(hh = max(hh2019, na.rm = TRUE)) %>%
  summarise(sum = sum(hh))

```

By this estimate, 119,850,107 (119850107) households have access to 25/3, which means 5.3 million households dont have access to service at that level. 

### The effect of the Internet for All Act

So what would happen if the Internet for All Act shifted the speed thresholds? Right now the FCC classifies speeds by 25/3, 100/10, 250/25, and 1000/100. But there is talk of 

```{r }

filter(dec2019) %>%
  filter(MaxAdDown>=25 & MaxAdUp>=25, !(TechCode == "60")) %>%
  group_by(BlockCode) %>%
  summarise(hh = max(hh2019, na.rm = TRUE)) %>%
  summarise(sum = sum(hh))

```

If the FCC were to adopt a symmetrical standard of 25/25, the number of households with a service drops to 112,082,260 (112082260). That's an additional 7.8 million households.

How much of the population?

```{r }

dec2019 %>%
  group_by(BlockCode) %>%
  filter(MaxAdDown>=25 & MaxAdUp>=25, !(TechCode == "60")) %>%
  summarise(max_pop = max(pop2019, na.rm = TRUE)) %>%
  summarise(sum = sum(max_pop))

```

Thats 296,788,253 (296788253) people. That's 35 million without the service. 

```{r }

filter(dec2019) %>%
  filter(MaxAdDown>=50 & MaxAdUp>=50, !(TechCode == "60")) %>%
  group_by(BlockCode) %>%
  summarise(hh = max(hh2019, na.rm = TRUE)) %>%
  summarise(sum = sum(hh))

```




```{r }

filter(dec2019) %>%
  filter(MaxAdDown>=100 & MaxAdUp>=100, !(TechCode == "60")) %>%
  group_by(BlockCode) %>%
  summarise(hh = max(hh2019, na.rm = TRUE)) %>%
  summarise(sum = sum(hh))

```



```{r }

filter(dec2019) %>%
  filter(MaxAdDown>=100 & MaxAdUp>=10, !(TechCode == "60")) %>%
  group_by(BlockCode) %>%
  summarise(hh = max(hh2019, na.rm = TRUE)) %>%
  summarise(sum = sum(hh))

```




```{r }

twenup <- dec2019 %>%
  filter(MaxAdDown==25, !(TechCode == "60")) %>%
  count(., MaxAdUp) %>%
  collect()

```

How many service plans are there at the 25 Mbps level?

```{r }

sum(twenup$n)

```

Lets make a new column for our dataframe that converts the service to a percentage. 

```{r }

twenup <- twenup %>%
  mutate(per=n/(sum(twenup$n))*100)

```

Now let's plot that.

```{r }

barplot(twenup$per, names=twenup$MaxAdUp,
        xlab = "Upload speed",
        ylab = "Percentage of all services",
        main = "Upload speeds offered by Internet services with 25 Mbps download")

```

Condensing all of the code, let's do that for 50. 

```{r }

fifup <- dec2019 %>%
  filter(MaxAdDown==50, !(TechCode == "60")) %>%
  count(., MaxAdUp) %>%
  collect()

fifup <- fifup %>%
  mutate(per=n/(sum(fifup$n))*100)

barplot(fifup$per, names=fifup$MaxAdUp,
        xlab = "Upload speed",
        ylab = "Percentage of all services",
        main = "Upload speeds offered by Internet services with 50 Mbps download")

```

Now let's do 100.

```{r }

hundup <- dec2019 %>%
  filter(MaxAdDown==100, !(TechCode == "60")) %>%
  count(., MaxAdUp) %>%
  collect()

hundup <- hundup %>%
  mutate(per=n/(sum(hundup$n))*100)

barplot(hundup$per, names=hundup$MaxAdUp,
        xlab = "Upload speed",
        ylab = "Percentage of all services",
        main = "Upload speeds offered by Internet services with 100 Mbps download")

```

