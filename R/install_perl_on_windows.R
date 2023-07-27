library (fs)
#library (httr)

install_strawberry_perl = function () {
  appdata = Sys.getenv('APPDATA')

  bd_path    = path (appdata, 'BiodiverseR')
  extract_to = dir_create (bd_path, 'sp5380')

  #  hard coded is suboptimal
  sp_url = 'https://github.com/StrawberryPerl/Perl-Dist-Strawberry/releases/download/SP_5380_5361/strawberry-perl-5.38.0.1-64bit-PDL.zip'
  sp_zip = path(bd_path, 'strawberry-perl-5.38.0.1-64bit-PDL.zip')


  if (!dir_exists (extract_to)) {
    dir_create(extract_to)
  }

  if (!file_exists(sp_zip)) {
    download.file (sp_url, sp_zip)
    unzip (sp_zip, exdir = extract_to)
  }

  old_path = Sys.getenv('PATH')
  old_wd = getwd()
  tryCatch ( {

      p <- Sys.getenv("PATH") |> strsplit(";") |> unlist()
      #p <- p[!grepl("rtools", p)]
      p <- grep (pattern="rtools", p, invert=TRUE, value=TRUE)
      p <- c(
        path (extract_to, "c/bin"),
        path (extract_to, "perl/site/bin"),
        path (extract_to, "perl/bin"),
        unlist (p)
      )
      Sys.setenv(PATH = paste(p, collapse=";"))
      #paste(p, collapse=";")
      Sys.setenv(PERL_CPANM_HOME = path(extract_to, "data"))
      #system ("where cpanm")
      system ("cpanm -v --notest Win32::LongPath")  #  test issues under 5.38.0
      system ("cpanm -v https://github.com/shawnlaffan/biodiverse.git")
      setwd ("inst/perl")
      system ("cpanm -v --installdeps .")
      Sys.setenv(PATH = old_path)
      setwd(old_wd)
    },
    error=function(err){
      message(paste("We hit an error:  ", err))
      Sys.setenv(PATH = old_path)
      setwd(old_wd)
      stop()
    },
    #  prob not needed now
    finally = function () {
      Sys.setenv(PATH = old_path)
      setwd(old_wd)
    }
  )


}
