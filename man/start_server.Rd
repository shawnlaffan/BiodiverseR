% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/start_server.R
\name{start_server}
\alias{start_server}
\title{Start the Biodiverse server}
\usage{
start_server(port = 0, use_exe = FALSE, perl_path = "")
}
\arguments{
\item{port}{integer}

\item{use_exe}{boolean}

\item{perl_path}{character}
}
\description{
Starts a Biodiverse server.
The server is shut down when the process object is garbage collected,
or an explicit kill command is called on it.
}
\details{
By default it will find an empty port, but you can select one if you so choose.

This should not really be exported and is currently here for dev purposes
}
\examples{
if(interactive()) {
  start_server(port=3001, use_exe=FALSE)
}
}
