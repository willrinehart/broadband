---
title: "Resources"
output: html_document
knit: (function(input_file, encoding) {
  out_dir <- 'docs';
  rmarkdown::render(input_file,
 encoding=encoding,
 output_file=file.path(dirname(input_file), out_dir, 'index.html'))})
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

# Broadband statistics 

I am beginning a massive project on broadband effects, which will live in this repo.

First and foremost, be sure to check out Michael Kotrous [repo](https://github.com/michaelkotrous/form477-panels/), which supports his academic work in broadband.

#### Federal Communications Commission official data

* [Raw Form 477 data](https://www.fcc.gov/general/broadband-deployment-data-fcc-form-477)

* [Internet Access Service Report data](https://www.fcc.gov/internet-access-services-reports)

* [List of 40 specialized FCC databases, such as radio call signs and equipment authorization](https://www.fcc.gov/licensing-databases/search-fcc-databases)
