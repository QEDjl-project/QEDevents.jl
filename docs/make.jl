using QEDevents
using Documenter

DocMeta.setdocmeta!(QEDevents, :DocTestSetup, :(using QEDevents); recursive = true)

makedocs(;
    modules = [QEDevents],
    authors = "Uwe Hernandez Acosta <u.hernandez@hzdr.de>, Simeon Ehrig, Klaus Steiniger, Tom Jungnickel, Anton Reinhard",
    repo = Documenter.Remotes.GitHub("QEDjl-project", "QEDevents.jl"),
    sitename = "QEDevents.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        edit_link = "main",
        assets = String[],
    ),
    pages = ["Home" => "index.md"],
)
deploydocs(repo = "github.com/QEDjl-project/QEDevents.jl.git", push_preview = false)
