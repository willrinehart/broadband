---
title: "R Notebook"
output:
  pdf_document: default
  html_notebook: default
editor_options:
  markdown:
    wrap: 72
---

```{r, message=FALSE, echo=FALSE}
knitr::opts_chunk$set(echo = TRUE)
library(easypackages)
libraries("readxl","ggplot2","stringr", "rlist", "data.table", "DBI", "stats",
          "RSQLite", "stargazer", "Hmisc","magrittr","formattable", "sf",
          "RPostgreSQL", "dplyr", "tidyverse", "dbplyr", "pbapply","stargazer",
          "quantreg", "olsrr","faraway", "binaryLogic", "ggthemes","plotly", 
          "tseries", "MASS", "labelled", "ordinal", "VGAM", "foreign", "haven")
options(scipen=999)

```

First read in the data and then convert it to time series format for
analysis.

```{r}
library(haven)
library(dplyr)
library(purrr)

CGOpoll <- read_sav("data/CGO_poll/TCGO0006_OUTPUT.sav")
CGOdf <- read_sav("data/CGO_poll/TCGO0006_OUTPUT.sav") 

variables_with_labels <- map(CGOdf, function(x) attr(x, "labels") != NULL) %>% 
  unlist() %>% 
  names()

CGOdf <- CGOdf %>%
  mutate_at(vars(variables_with_labels), as_factor)



```

Let's get all of the names.

```{r}
data.frame(names(CGOpoll))
```

From the codebook, some of the key variables of interest:

Name: harm_1 Description: Harm -- How much harm do you believe social
media causes to children versus the benefits it provides?

| Count | Code | Label                 |
|-------|------|-----------------------|
| 93    | 1    | Only harm 1           |
| 502   | 2    | More harm than good 2 |
| 286   | 3    | Equal good and harm 3 |
| 97    | 4    | More good than harm 4 |
| 22    | 5    | Only good 5           |

-   harm_1 Harm \-- How much harm do you believe social media causes to
    children versus the benefits it provides?

-   trust_child_1 Trust for children \-- Facebook

-   trust_child_2 Trust for children \-- Instagram

-   trust_child_3 Trust for children \-- Twitter

-   trust_child_4 Trust for children \-- Snapchat

-   trust_child_5 Trust for children \-- Reddit

-   trust_child_6 Trust for children \-- TikTok

-   trust_child_7 Trust for children \-- Youtube

-   trust_child_8 Trust for children \-- Amazon

-   potential_harm_1 Damage to mental health

-   potential_harm_2 Exposure to graphic violence

-   potential_harm_3 Exposure to sexually explicit material

-   potential_harm_4 Content that encourages dangerous or harmful
    behavior

-   potential_harm_5 Radicalization

-   potential_harm_6 Exposure to predators

-   potential_harm_7 Access to drugs

-   potential_harm_8 Exposure to surveillance

-   potential_harm_9 Targeted advertising

-   potential_harm_10 Online addiction

-   potential_harm_11 None

And here are the conditionals:

-   birthyr Birth Year

-   gender Gender

-   race Race

-   educ Education

-   marstat Marital Status

-   employ Employment Status

-   faminc_new Family income

-   child18 Children under age 18 in household

-   pid3 3 point party ID

-   pid7 7 point Party ID

-   presvote16post 2016 President Vote Post Election

-   presvote20post 2020 President Vote Post Election

-   inputstate State of Residence

-   votereg Voter Registration Status

-   ideo5 Ideology

-   newsint Political Interest

-   religpew Religion

-   pew_churatd Church attendance (Pew version)

-   pew_bornagain Born Again (Pew version)

-   pew_religimp Importance of religion (Pew version)

-   pew_prayer Frequency of Prayer (Pew version)

Let's create a couple of probability function.

First let's go with ordinal. See:

-   <https://stats.oarc.ucla.edu/other/mult-pkg/faq/ologit/>
-   <https://stats.oarc.ucla.edu/r/dae/ordinal-logistic-regression/>
-   <https://www.r-bloggers.com/2019/06/how-to-perform-ordinal-logistic-regression-in-r/>

```{r}
CGOdf <- mutate(CGOdf, age=(2023-birthyr))

```

```{r}
model1 <- vglm(harm_1 ~ age + gender + race + educ + marstat + employ + 
               faminc_new + child18, 
               family=multinomial(), 
               data = CGOdf)
summary(model1)
```

```{r}
#fit1 <- polr(harm_1 ~ age + gender + race + educ + marstat + employ + 
#               faminc_new + child18, 
#             data = CGOdf, Hess = TRUE)
# summary(fit1)

```

```{r}
#summary_table <- coef(summary(fit1))
#pval <- pnorm(abs(summary_table[, "t value"]),lower.tail = FALSE)* 2
#summary_table <- cbind(summary_table, "p value" = round(pval,3))
#summary_table
```

race + educ + marstat + employ + faminc_new + child18

-   pid3 3 point party ID

-   pid7 7 point Party ID

-   presvote16post 2016 President Vote Post Election

-   presvote20post 2020 President Vote Post Election

-   inputstate State of Residence


```{r}
teen <- read.csv("TeensmentalhealthdataandtechuseSheet6.csv", header=T)
time_series <- ts(teen$Total.suicide.rate, start = 1968, frequency = 1)
```

Let's plot what we have so far.

```{r}
plot(time_series)
```

So next, let's take the first differences.

```{r}
diffts <- diff(time_series)
ts.plot(diffts)
minor.tick()
```

```{r}
diffdf <- data.frame(Y=as.matrix(diffts), date=time(diffts))
```

```{r}

acfRes <- acf(time_series)
pacfRes <- pacf(time_series) 

```

Add a new chunk by clicking the *Insert Chunk* button on the toolbar or
by pressing *Cmd+Option+I*.

When you save the notebook, an HTML file containing the code and output
will be saved alongside it (click the *Preview* button or press
*Cmd+Shift+K* to preview the HTML file).

The preview shows you a rendered HTML copy of the contents of the
editor. Consequently, unlike *Knit*, *Preview* does not run any R code
chunks. Instead, the output of the chunk when it was last run in the
editor is displayed.

teen \<- read.csv("TeensmentalhealthdataandtechuseSheet6.csv", header=T)

time_series \<- ts(teen\$Total.suicide.rate, start = 1968, frequency =
1)

diffts \<- diff(time_series)

# Plot dz

ts.plot(diffts)
