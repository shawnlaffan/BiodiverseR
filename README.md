
<!-- README.md is generated from README.Rmd. Please edit that file -->

**NOTE: This is a package template, which will be used to provide an
interface to the Biodiverse tool. **

# BiodiverseR

<!-- badges: start -->

<!-- badges: end -->

Provides and interface to functionalities available in the Biodiverse.
Biodiverse is a tool for the spatial analysis of diversity using indices
based on taxonomic, phylogenetic, trait and matrix-based (e.g. genetic
distance) relationships, as well as related environmental and temporal
variations. More information is available at its [Github
page](https://github.com/shawnlaffan/biodiverse).

## Installation

You can install BiodiverseR like so:

``` r
devtools::install_github("shawnlaffan/BiodiverseR")
```

## Quick demo

Checking that the Biodiverse tool can be accessed:

``` r
library(BiodiverseR)
cs = create_service("test")
#> [1] "test"
#check_service(cs)
```
