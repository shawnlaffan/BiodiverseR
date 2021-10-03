## Description =====
## In this script we follow the https://r-pkgs.org/index.html which demonstrates 
## how to create a package

## Install packages, which are not available and load them ====
# Packages for loading
packages = c("devtools", "tidyverse", "fs", "rstudioapi")

# Install packages not yet installed
installed_packages = packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Load packages
invisible(lapply(packages, library, character.only = TRUE))

## Create package BiodiverseR ====
# Get current working directory of this script
wd = dirname(rstudioapi::getSourceEditorContext()$path)

# Create a cross-platform path; go one level up as creating a package structure 
# in the same version controlled folder is not desired.
# CRAN requires that package name should contain only (ASCII) letters, numbers
# and dot, have at least two characters and start with a letter and not end in 
# a dot. More details are available here: 
# https://cran.r-project.org/doc/manuals/r-devel/R-exts.html#Creating-R-packages
path_cp = path(paste0(gsub("Biodiverse-R", "", wd), "/BiodiverseR"))

# Create BiodiverseR package
create_package(path_cp)

# A package structure and a separate BiodiverseR repository was created.

