

strawberry_path = paste (paste(Sys.getenv("PATH"), paste (r"(C:/shawn/perls/5.32.1.1_PDL)", c("c/bin", "perl/bin", "perl/site/bin"), sep="/")), collapse=";")
strawberry_path = paste (r"(C:/shawn/perls/5.32.1.1_PDL)", c("c/bin", "perl/bin", "perl/site/bin"), sep="/")


path_array = strsplit (Sys.getenv("PATH"), ";")
p = unlist(append(strawberry_path, path_array))

p = paste (p, collapse = ";")
Sys.setenv("PATH" = p)
