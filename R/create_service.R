#' Create service
#'
#' Create a service which allows us to access functionalities of the Biodiverse
#' tool.
#'
#' @param path_net_str string, path_service_str string
#'
#' @export
#' @examples
#' create_service("C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319", "path")

create_service = function(path_net_str, path_service_str){
  path_net_str =
  # Check if BiodiverseService exists
  service_flag = shell("sc interrogate BiodiverseService")

  # If service doesn't exist
  if (service_flag == 1060) { # No service installed
    path_install = paste0(path_net_str, '\\InstallUtil.exe ', path_service_str)
    service_install = shell(path_install)
  }

  # Run service to initalise
  if (service_install == 0) { # If service was installed correctly
    # Check if service exists
    service_flag = shell("sc interrogate BiodiverseService")
    if (service_flag == 1062) { # The service exists but hasn't been started
      serviceInitialise = shell('sc start BiodiverseService')
    }
  }

  # Run service to send commands
  if (service_install == 0) { # If service was installed correctly
    # Check if service exists
    service_flag = shell("sc interrogate BiodiverseService")
    if (service_flag == 1062) { # The service exists but hasn't been started.
      serviceInitialise = shell('sc start BiodiverseService param1 param2')
    }
  }

  # Print input to screen
  print(path_net_str)
}
