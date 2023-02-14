R Notebook
================

    ## Warning: package 'readxl' was built under R version 4.1.1

    ## Warning: package 'ggplot2' was built under R version 4.1.1

    ## Warning: package 'stringr' was built under R version 4.1.1

    ## Warning: package 'rlist' was built under R version 4.1.1

    ## Warning: package 'data.table' was built under R version 4.1.1

    ## Warning: package 'DBI' was built under R version 4.1.1

    ## Warning: package 'RSQLite' was built under R version 4.1.1

    ## Warning: package 'stargazer' was built under R version 4.1.1

    ## Warning: package 'Hmisc' was built under R version 4.1.1

    ## Warning: package 'lattice' was built under R version 4.1.1

    ## Warning: package 'survival' was built under R version 4.1.1

    ## Warning: package 'magrittr' was built under R version 4.1.1

    ## Warning: package 'sf' was built under R version 4.1.1

    ## Warning: package 'RPostgreSQL' was built under R version 4.1.1

    ## Warning: package 'dplyr' was built under R version 4.1.1

    ## Warning: package 'tidyverse' was built under R version 4.1.1

    ## Warning: package 'tibble' was built under R version 4.1.1

    ## Warning: package 'tidyr' was built under R version 4.1.1

    ## Warning: package 'readr' was built under R version 4.1.1

    ## Warning: package 'purrr' was built under R version 4.1.1

    ## Warning: package 'forcats' was built under R version 4.1.1

    ## Warning: package 'dbplyr' was built under R version 4.1.1

    ## Warning: package 'pbapply' was built under R version 4.1.1

    ## Warning: package 'quantreg' was built under R version 4.1.1

    ## Warning: package 'olsrr' was built under R version 4.1.1

    ## Warning: package 'faraway' was built under R version 4.1.1

    ## Warning in library(package, lib.loc = lib.loc, character.only = TRUE,
    ## logical.return = TRUE, : there is no package called 'ggthemes'

    ## Warning: package 'plotly' was built under R version 4.1.1

    ## Warning: package 'tseries' was built under R version 4.1.1

    ## Warning: package 'MASS' was built under R version 4.1.1

    ## Warning: package 'labelled' was built under R version 4.1.1

    ## Warning: package 'ordinal' was built under R version 4.1.1

    ## Warning: package 'VGAM' was built under R version 4.1.1

    ## Warning: package 'foreign' was built under R version 4.1.1

    ## Warning: package 'haven' was built under R version 4.1.1

First read in the data and then convert it to time series format for
analysis.

``` r
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

    ## Warning: Using an external vector in selections was deprecated in tidyselect 1.1.0.
    ## ℹ Please use `all_of()` or `any_of()` instead.
    ##   # Was:
    ##   data %>% select(variables_with_labels)
    ## 
    ##   # Now:
    ##   data %>% select(all_of(variables_with_labels))
    ## 
    ## See <https://tidyselect.r-lib.org/reference/faq-external-vector.html>.

Let’s get all of the names.

``` r
data.frame(names(CGOpoll))
```

    ##        names.CGOpoll.
    ## 1              caseid
    ## 2              weight
    ## 3             trust_1
    ## 4             trust_2
    ## 5             trust_3
    ## 6             trust_4
    ## 7             trust_5
    ## 8             trust_6
    ## 9             trust_7
    ## 10            trust_8
    ## 11            trust_9
    ## 12           trust_10
    ## 13           trust_11
    ## 14           trust_12
    ## 15          bet_wor_1
    ## 16          bet_wor_2
    ## 17          bet_wor_3
    ## 18          bet_wor_4
    ## 19          bet_wor_5
    ## 20          bet_wor_6
    ## 21          bet_wor_7
    ## 22          bet_wor_8
    ## 23            agree_1
    ## 24            agree_2
    ## 25            agree_3
    ## 26            agree_9
    ## 27           agree_10
    ## 28           agree_11
    ## 29           agree_12
    ## 30           agree_13
    ## 31           agree_23
    ## 32           agree_24
    ## 33           agree_20
    ## 34           agree_25
    ## 35           agree_26
    ## 36           agree2_1
    ## 37           agree2_2
    ## 38           agree2_3
    ## 39           agree2_4
    ## 40             harm_1
    ## 41      trust_child_1
    ## 42      trust_child_2
    ## 43      trust_child_3
    ## 44      trust_child_4
    ## 45      trust_child_5
    ## 46      trust_child_6
    ## 47      trust_child_7
    ## 48      trust_child_8
    ## 49   potential_harm_1
    ## 50   potential_harm_2
    ## 51   potential_harm_3
    ## 52   potential_harm_4
    ## 53   potential_harm_5
    ## 54   potential_harm_6
    ## 55   potential_harm_7
    ## 56   potential_harm_8
    ## 57   potential_harm_9
    ## 58  potential_harm_10
    ## 59  potential_harm_11
    ## 60           agree3_1
    ## 61           agree3_2
    ## 62           agree3_3
    ## 63           agree3_4
    ## 64           agree3_5
    ## 65           agree3_6
    ## 66                 q1
    ## 67                 q2
    ## 68                 q3
    ## 69                 q4
    ## 70                 q5
    ## 71                 q6
    ## 72                 q7
    ## 73           agree4_1
    ## 74           agree4_2
    ## 75           agree4_3
    ## 76           agree4_4
    ## 77           agree4_5
    ## 78           agree4_6
    ## 79            birthyr
    ## 80             gender
    ## 81               race
    ## 82               educ
    ## 83            marstat
    ## 84             employ
    ## 85         faminc_new
    ## 86            child18
    ## 87               pid3
    ## 88               pid7
    ## 89     presvote16post
    ## 90     presvote20post
    ## 91         inputstate
    ## 92            votereg
    ## 93              ideo5
    ## 94            newsint
    ## 95           religpew
    ## 96        pew_churatd
    ## 97      pew_bornagain
    ## 98       pew_religimp
    ## 99         pew_prayer
    ## 100         starttime
    ## 101           endtime

From the codebook, some of the key variables of interest:

Name: harm_1 Description: Harm – How much harm do you believe social
media causes to children versus the benefits it provides?

| Count | Code | Label                 |
|-------|------|-----------------------|
| 93    | 1    | Only harm 1           |
| 502   | 2    | More harm than good 2 |
| 286   | 3    | Equal good and harm 3 |
| 97    | 4    | More good than harm 4 |
| 22    | 5    | Only good 5           |

- harm_1 Harm -- How much harm do you believe social media causes to
  children versus the benefits it provides?

- trust_child_1 Trust for children -- Facebook

- trust_child_2 Trust for children -- Instagram

- trust_child_3 Trust for children -- Twitter

- trust_child_4 Trust for children -- Snapchat

- trust_child_5 Trust for children -- Reddit

- trust_child_6 Trust for children -- TikTok

- trust_child_7 Trust for children -- Youtube

- trust_child_8 Trust for children -- Amazon

- potential_harm_1 Damage to mental health

- potential_harm_2 Exposure to graphic violence

- potential_harm_3 Exposure to sexually explicit material

- potential_harm_4 Content that encourages dangerous or harmful behavior

- potential_harm_5 Radicalization

- potential_harm_6 Exposure to predators

- potential_harm_7 Access to drugs

- potential_harm_8 Exposure to surveillance

- potential_harm_9 Targeted advertising

- potential_harm_10 Online addiction

- potential_harm_11 None

And here are the conditionals:

- birthyr Birth Year

- gender Gender

- race Race

- educ Education

- marstat Marital Status

- employ Employment Status

- faminc_new Family income

- child18 Children under age 18 in household

- pid3 3 point party ID

- pid7 7 point Party ID

- presvote16post 2016 President Vote Post Election

- presvote20post 2020 President Vote Post Election

- inputstate State of Residence

- votereg Voter Registration Status

- ideo5 Ideology

- newsint Political Interest

- religpew Religion

- pew_churatd Church attendance (Pew version)

- pew_bornagain Born Again (Pew version)

- pew_religimp Importance of religion (Pew version)

- pew_prayer Frequency of Prayer (Pew version)

Let’s create a couple of probability function.

First let’s go with ordinal. See:

- <https://stats.oarc.ucla.edu/other/mult-pkg/faq/ologit/>
- <https://stats.oarc.ucla.edu/r/dae/ordinal-logistic-regression/>
- <https://www.r-bloggers.com/2019/06/how-to-perform-ordinal-logistic-regression-in-r/>

``` r
CGOdf <- mutate(CGOdf, age=(2023-birthyr))
```

``` r
model1 <- vglm(harm_1 ~ age + gender + race + educ + marstat + employ + 
               faminc_new + child18, 
               family=multinomial(), 
               data = CGOdf)
summary(model1)
```

    ## 
    ## Call:
    ## vglm(formula = harm_1 ~ age + gender + race + educ + marstat + 
    ##     employ + faminc_new + child18, family = multinomial(), data = CGOdf)
    ## 
    ## Coefficients: 
    ##                Estimate Std. Error z value Pr(>|z|)   
    ## (Intercept):1 -5.027387   1.676328  -2.999  0.00271 **
    ## (Intercept):2 -4.643417   1.566980  -2.963  0.00304 **
    ## (Intercept):3 -4.725889   1.584769  -2.982  0.00286 **
    ## (Intercept):4 -4.806935   1.661330  -2.893  0.00381 **
    ## age:1          0.048052   0.022435   2.142  0.03220 * 
    ## age:2          0.058312   0.021596   2.700  0.00693 **
    ## age:3          0.041308   0.021712   1.903  0.05710 . 
    ## age:4          0.039301   0.022352   1.758  0.07870 . 
    ## gender:1       0.098362   0.501184   0.196  0.84441   
    ## gender:2       0.471722   0.464216   1.016  0.30955   
    ## gender:3       0.455166   0.469996   0.968  0.33282   
    ## gender:4      -0.093915   0.496853  -0.189  0.85008   
    ## race:1         0.840819   0.345101   2.436  0.01483 * 
    ## race:2         0.682616   0.340613   2.004  0.04506 * 
    ## race:3         0.751793   0.341346   2.202  0.02763 * 
    ## race:4         0.720902   0.345843   2.084  0.03712 * 
    ## educ:1        -0.161789   0.168274  -0.961  0.33632   
    ## educ:2        -0.026638   0.156200  -0.171  0.86459   
    ## educ:3        -0.061616   0.158037  -0.390  0.69662   
    ## educ:4         0.065929   0.166600   0.396  0.69230   
    ## marstat:1      0.014623   0.157238   0.093  0.92590   
    ## marstat:2      0.002451   0.147390   0.017  0.98673   
    ## marstat:3      0.082970   0.148668   0.558  0.57678   
    ## marstat:4      0.079377   0.156234   0.508  0.61141   
    ## employ:1       0.266662   0.171857   1.552  0.12074   
    ## employ:2       0.291558   0.166701   1.749  0.08029 . 
    ## employ:3       0.273217   0.167433   1.632  0.10272   
    ## employ:4       0.276518   0.171488   1.612  0.10686   
    ## faminc_new:1   0.020903   0.021080   0.992  0.32138   
    ## faminc_new:2   0.018825   0.020870   0.902  0.36704   
    ## faminc_new:3   0.020089   0.020895   0.961  0.33635   
    ## faminc_new:4   0.012046   0.021281   0.566  0.57137   
    ## child18:1      1.745313   0.617311   2.827  0.00469 **
    ## child18:2      1.763317   0.566584   3.112  0.00186 **
    ## child18:3      1.871619   0.574013   3.261  0.00111 **
    ## child18:4      1.674749   0.609494   2.748  0.00600 **
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Names of linear predictors: log(mu[,1]/mu[,5]), log(mu[,2]/mu[,5]), 
    ## log(mu[,3]/mu[,5]), log(mu[,4]/mu[,5])
    ## 
    ## Residual deviance: 2357.928 on 3964 degrees of freedom
    ## 
    ## Log-likelihood: -1178.964 on 3964 degrees of freedom
    ## 
    ## Number of Fisher scoring iterations: 8 
    ## 
    ## No Hauck-Donner effect found in any of the estimates
    ## 
    ## 
    ## Reference group is level  5  of the response

``` r
#fit1 <- polr(harm_1 ~ age + gender + race + educ + marstat + employ + 
#               faminc_new + child18, 
#             data = CGOdf, Hess = TRUE)
# summary(fit1)
```

``` r
#summary_table <- coef(summary(fit1))
#pval <- pnorm(abs(summary_table[, "t value"]),lower.tail = FALSE)* 2
#summary_table <- cbind(summary_table, "p value" = round(pval,3))
#summary_table
```

race + educ + marstat + employ + faminc_new + child18

- pid3 3 point party ID

- pid7 7 point Party ID

- presvote16post 2016 President Vote Post Election

- presvote20post 2020 President Vote Post Election

- inputstate State of Residence

``` r
teen <- read.csv("TeensmentalhealthdataandtechuseSheet6.csv", header=T)
time_series <- ts(teen$Total.suicide.rate, start = 1968, frequency = 1)
```

Let’s plot what we have so far.

``` r
plot(time_series)
```

![](CGOpolling_files/figure-gfm/unnamed-chunk-9-1.png)<!-- -->

So next, let’s take the first differences.

``` r
diffts <- diff(time_series)
ts.plot(diffts)
minor.tick()
```

![](CGOpolling_files/figure-gfm/unnamed-chunk-10-1.png)<!-- -->

``` r
diffdf <- data.frame(Y=as.matrix(diffts), date=time(diffts))
```

``` r
acfRes <- acf(time_series)
```

![](CGOpolling_files/figure-gfm/unnamed-chunk-12-1.png)<!-- -->

``` r
pacfRes <- pacf(time_series) 
```

![](CGOpolling_files/figure-gfm/unnamed-chunk-12-2.png)<!-- -->

Add a new chunk by clicking the *Insert Chunk* button on the toolbar or
by pressing *Cmd+Option+I*.

When you save the notebook, an HTML file containing the code and output
will be saved alongside it (click the *Preview* button or press
*Cmd+Shift+K* to preview the HTML file).

The preview shows you a rendered HTML copy of the contents of the
editor. Consequently, unlike *Knit*, *Preview* does not run any R code
chunks. Instead, the output of the chunk when it was last run in the
editor is displayed.

teen \<- read.csv(“TeensmentalhealthdataandtechuseSheet6.csv”, header=T)

time_series \<- ts(teen\$Total.suicide.rate, start = 1968, frequency =
1)

diffts \<- diff(time_series)

# Plot dz

ts.plot(diffts)
