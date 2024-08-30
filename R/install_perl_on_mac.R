#' Set Perl up on non-Windows Machine
#'
#' @param perl_version character string specifying version of perl needed
#' @importFrom perlbrewr perlbrew
#' @export

init_perlbrewr <- function(perl_version){
  # Perlbrewr function to tell R to use perlbrew

  if (perl_version == NULL) {
    available = perlbrewr::perlbrew_list()
    perl_version = attr(available, "active")
    if (perl_version == NULL) {
        perl_version = available[1]
    }
  }
  
  # Check if root path exists in environment, if not set it
  # TODO:Currently not working
  # if(Sys.getenv("PERLBREW_ROOT") == "")
  # result <- perlbrewr::perlbrew(root = "~/perl5/perlbrew/bin/perlbrew", version = perl_version)
  #else
    result <- perlbrewr::perlbrew(root = Sys.getenv("PERLBREW_ROOT"), version = perl_version)

    return(result)
}
