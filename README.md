# Biodiverse-R
R interface for Biodiverse

## Work plan
The following tasks are required:
- creating a template for R package
- adding relevant binaries to R package
- creating a binary for testing, eg console application in C#, which will act as a service
- setting up a link between R package and Biodiverse engine in perl
- expanding the link to all required functionalities of the Biodiverse engine
- testing and workflows

## Notes
- Biodiverse engine will be provided as an exe file
- all operating systems should be considered for deployment
- system based invocation of initial binaries is expected (INSTSRV.EXE ? SRVANY.EXE?)
- Biodiverse engine should act as a service
- no camel case; snake case convention preferred; "=" should be aligned; readability
- JSON format as a way to pass information between the service and Biodiverse tool
- Biodiverse tool functionalities can be exposed in an automated fashon; no need to expose each function seperately
- testing can be performed within the R package structure
- Github actions will be used for testing workflows
- optimise memory to avoid memory allocation issues in R if possible

## Links
[R package creation 1](https://r-pkgs.org/index.html)
[R package creation 2](https://tinyheero.github.io/jekyll/update/2015/07/26/making-your-first-R-package.html)
[Perl as service](https://www.sevenforums.com/general-discussion/271670-perl-file-pl-file-arguments-windows-service.html)
