#' Set Perl up on macOS
#'
#' @param perl_version
#' @export

install_perlbrewr <- function(perl_version = "5.36.1"){
  # Perlbrewr function to tell R to use perlbrew

  # Check if root path exists in environment, if not set it
  # TODO:Currently not working
  # if(Sys.getenv("PERLBREW_ROOT") == "")
  # result <- perlbrewr::perlbrew(root = "~/perl5/perlbrew/bin/perlbrew", version = perl_version)
  #else
    result <- perlbrewr::perlbrew(root = Sys.getenv("PERLBREW_ROOT"), version = perl_version)

    return(result)
}
