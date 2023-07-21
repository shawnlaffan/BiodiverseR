
<!-- README.md is generated from README.Rmd. Please edit that file -->

**NOTE: This is currently in development. **

# BiodiverseR

<!-- badges: start -->

[![R-CMD-check](https://github.com/shawnlaffan/Biodiverse-R/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/shawnlaffan/Biodiverse-R/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

Provides an R interface to the spatial analyses available in Biodiverse.
Biodiverse is a tool for the spatial analysis of diversity using indices
based on taxonomic, phylogenetic, trait and matrix-based (e.g. genetic
distance) relationships, as well as related environmental and temporal
variations. More information is available at its [Github
page](https://github.com/shawnlaffan/biodiverse).

## Installation

This is a two step process. First, install the Biodiverse engine.
Second, install the R package.

1.  Install the Biodiverse engine.

This currently requires a working perl interpreter in your path. (Future
versions will provide self contained executables).

On Windows a perl interpreter can be obtained through the [Strawberry
perl project](https://strawberryperl.com/releases.html). Most
unix-derived systems provide a perl interpreter but it is best to avoid
this and use a system like [perlbrew](https://perlbrew.pl/). Be sure to
also install the cpanm utility (see perlbrew site for details).

Once you have a perl installed and in your path you can install the perl
dependencies using cpanm at the command line. (Make sure to update the
below code to use the correct path separator on Windows). Note that this
requires that you have git installed on your system and in the path.

This code also assumes you have run a git clone of this repo and are at
the top level of this repo.

``` bash
cpanm https://github.com/shawnlaffan/biodiverse.git
cd inst/perl
cpanm --installdeps .
```

Note that the above will take a while if you do not already have the
GDAL development package installed on your system. This is because it
will compile its own version if it is unable to find one on the system
(but maybe this is not such a bad thing as then it will be isolated from
system changes).

If you want to see things as they happen then add the verbose flag to
the cpanm calls (`cpanm --verbose ...`).

2.  Install the R code

You can install the R code like so:

``` r
devtools::install_github("shawnlaffan/BiodiverseR")
```

## Quick demo

Check that the Biodiverse service can be accessed:

``` r
# It is critical that this be set to wherever you have downloaded the package 
#  as otherwise the system will not find the server code.  
#  It is an ugly and temporary hack and will not be needed in the future.
#  This version assumes you are at the top level of the BiodiverseR repository.  
Sys.setenv("Biodiverse_basepath" = getwd())

#  library(BiodiverseR)
devtools::load_all()  #  for during development 
cs = start_server()
cs$server_object$is_alive()

#  cleanup
rm(cs)
gc()  #  server is not deleted until garbage collected
```
