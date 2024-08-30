#' Set Perl up on non-Windows Machine
#'
#' @param perl_version character string specifying version of perl needed
#' @importFrom perlbrewr perlbrew
#' @export

init_perlbrewr <- function(perl_version = NULL, locallib = NULL){
  # Perlbrewr function to tell R to use perlbrew

  if (missing(perl_version)) {
    available = perlbrewr::perlbrew_list()
    perl_version = attr(available, "active")
    #message ("bbbbb ", perl_version)
    if (missing (perl_version)) {
        perl_version = available[1]
    }
    perl_version <- trimws(perl_version)
    message (paste0 ("Using system perlbrew version ", perl_version))
  }
  
  
  # Check if root path exists in environment, if not set it
  # TODO:Currently not working
  # if(Sys.getenv("PERLBREW_ROOT") == "")
  # result <- perlbrewr::perlbrew(root = "~/perl5/perlbrew/bin/perlbrew", version = perl_version)
  #else

    result <- perlbrewr::perlbrew(root = Sys.getenv("PERLBREW_ROOT"), version = perl_version, lib = locallib)

    if (missing(locallib)) {
        #  should use ~/Library on Macs
        #basepath = fs::path_home()
        #locallib  = fs::path (basepath, 'BiodiverseR', 'perl5')
        locallib = "BiodiverseR"
        success = perlbrewr::perlbrew_lib_create(
          lib = locallib, 
          version = perl_version, 
          perlbrew.use = TRUE
        )
        message (paste0 ("Setting locallib result was ", success))
    }
  
  return(result)
}


#  should be a wrapper to handle platform differences
#  should also allow local::lib
#  one day Biodiverse will be on cpan, which will simplify things below

#' install_perl_deps
#'
#' @param cpanfile Path to cpanfile or a directory to find one, defaults to the BiodiverseR cpanfile
#' @export
#' @rdname install_perl_deps
install_perl_deps <- function(cpanfile = NULL, installdeps = TRUE, bd_git_path = NULL, verbose = TRUE, ...) {
    if (missing(cpanfile)) {
        cpanfile = paste (system.file("perl", package ="BiodiverseR"), "cpanfile", sep="/")
    }
    
    #  This should be conditional on not having been run already
    #  init_perlbrewr(perl_version)

    os = get_os()
    
    if (os =="windows") {
        return (BiodiverseR::install_strawberry_perl())
    }
    
    #  should use ~/Library on Macs
    basepath = fs::path_home
    bd_path  = fs::path (basepath, 'BiodiverseR')
    
    if (missing (bd_git_path)) {
        bd_git_path = fs::path(bd_path, "biodiverse_git")

        if (!fs::dir_exists(bd_git_path)) {
          system2 (
            "git",
            args = c(
              "clone",
              "--depth", "1",
              "https://github.com/shawnlaffan/biodiverse.git",
              bd_git_path
            )
          )
        }
    }

    #old_wd = getwd()
    #setwd (bd_git_path)
    system2 ("git", "-C", bd__git_path, "pull")  #  run regardless
 #   system ("cpanm --verbose --installdeps .")
 #   system ("cpanm --verbose .")
    #setwd(old_wd)
    bd_cpanfile = fs::path (bd_git_path)
    perlbrewr::cpanm(installdeps = installdeps, dist = bd_cpanfile, verbose = verbose, ...)
    
    if(basename(cpanfile) == "cpanfile") {
        cpanfile <- dirname(cpanfile) 
    }
    perlbrewr::cpanm(installdeps = installdeps, dist = cpanfile, verbose = verbose, ...)
}

# https://www.r-bloggers.com/2015/06/identifying-the-os-from-r/
get_os <- function(){
  sysinf <- Sys.info()
  if (!is.null(sysinf)){
    os <- sysinf['sysname']
    if (os == 'Darwin')
      os <- "osx"
  } else { ## mystery machine
    os <- .Platform$OS.type
    if (grepl("^darwin", R.version$os))
      os <- "osx"
    if (grepl("linux-gnu", R.version$os))
      os <- "linux"
  }
  tolower(os)
}
