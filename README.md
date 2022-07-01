---
output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->



**NOTE: This is currently in development. **

# BiodiverseR    

<!-- badges: start -->
[![R-CMD-check](https://github.com/shawnlaffan/Biodiverse-R/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/shawnlaffan/Biodiverse-R/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

Provides an interface to functionalities available in Biodiverse. Biodiverse 
is a tool for the spatial analysis of diversity using indices based on taxonomic, 
phylogenetic, trait and matrix-based (e.g. genetic distance) relationships, 
as well as related environmental and temporal variations. More information is 
available at its [Github page](https://github.com/shawnlaffan/biodiverse).

## Installation

This currently requires a working perl interpreter in your path.
(Future versions will provide self contained executables).

On Windows a perl interpreter can be obtained through the [Strawberry perl project](https://strawberryperl.com/releases.html).
Most unix-derived systems provide a perl interpreter but it is best to avoid this and use
a system like [perlbrew](https://perlbrew.pl/).  Be sure to also install the cpanm utility (see
perlbrew site for details).  

Once you have a perl installed and in your path you can install the perl dependencies using
cpanm at the command line.  (Make sure to update the below code to use the correct path separator
on Windows).

``` bash
cpanm https://github.com/shawnlaffan/biodiverse.git
cd inst/perl
cpanm --installdeps .
```

Note that the above will take a while if you do not already have the GDAL development
package installed on your system.  This is because it will compile its own version if
it is unable to find one on the system (but maybe this is not such a bad thing as then
it will be isolated from system changes).

You can install the R code like so:

``` r
devtools::install_github("shawnlaffan/BiodiverseR")
```
  
## Quick demo

Check that the Biodiverse service can be accessed:


```r
#  An ugly and temporary hack so we can find the relevant perl code.
#  Set this to wherever you have downloaded the package to.  
Sys.setenv("Biodiverse_basepath" = getwd())

#  library(BiodiverseR)
devtools::load_all()  #  for during development 
#> ℹ Loading BiodiverseR
cs = start_server()
#> server_path is /mnt/c/shawn/git/BiodiverseR/inst/perl/script/BiodiverseR
#> Command: /mnt/c/shawn/git/BiodiverseR/inst/perl/script/BiodiverseR daemon -l http://127.0.0.1:9611
#> /mnt/c/shawn/git/BiodiverseR/inst/perl/script/BiodiverseR
#> Server still coming up, trying again in 1 second (attempt 1 of 10)
cs$process_object$is_alive()
#> [1] TRUE

#  cleanup
rm(cs)
gc()  #  server is not deleted until garbage collected
#>           used (Mb) gc trigger (Mb) max used (Mb)
#> Ncells  792451 42.4    1371984 73.3  1371984 73.3
#> Vcells 1427486 10.9    8388608 64.0  3022574 23.1
```
