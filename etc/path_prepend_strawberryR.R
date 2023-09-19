


strawberry_path = r"(C:/shawn/perls/5.38.0.1_PDL/perl/bin)"

path_array = strsplit (Sys.getenv("PATH"), ";")
p = unlist(append(strawberry_path, path_array))

p = paste (p, collapse = ";")
Sys.setenv("PATH" = p)
