
using Pkg

Pkg.add(; url="https://github.com/QEDjl-project/QEDcore.jl", rev="dev")
@warn "This repository depends on the dev branch of QEDcore.jl\n It is NOT ready for release!"

#Pkg.add(; url="https://github.com/QEDjl-project/QEDbase.jl.git", rev="dev")
#@warn "This repository depends on the dev branch of QEDbase.jl\n It is NOT ready for release!"
