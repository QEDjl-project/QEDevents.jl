
@warn "This repository depends on the dev branch of QEDprocesses.jl\n It is NOT ready for release!"

using Pkg: Pkg
Pkg.add(; url="https://github.com/QEDjl-project/QEDprocesses.jl", rev="dev")
