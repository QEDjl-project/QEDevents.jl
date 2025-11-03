include("target.jl")

function testsuite_run(backend, vec_type, el_type)

    @testset "target evaluation" begin
        @testset "Compton" testsuite_Compton_target(
            backend,
            vec_type,
            el_type,
            256,
        )
    end

    return nothing
end
