using QEDevents
using Test
using SafeTestsets

@testset "QEDevents.jl" begin
    @time @safetestset "interfaces" begin
        include("interfaces.jl")
    end
end
