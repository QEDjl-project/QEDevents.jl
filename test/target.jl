RNG = Xoshiro(137137)

function _rand_compton_coords(ELTYPE, RNG, om, N)
    return [
        SVector(om, rand(RNG, ELTYPE) * 2 - one(ELTYPE), rand(RNG, ELTYPE) * 2 * pi) for
            _ in 1:N
    ]
end

function testsuite_Compton_target(backend, vec_type, el_type, N)
    if el_type == Float16 && !(backend isa CPU)
        return nothing
    end
    OMS = (el_type(1.0e-3), el_type(1.0))
    PROC = Compton()
    MODEL = PerturbativeQED()
    IN_PSL = ComptonRestSystem()
    OUT_PSL = ComptonSphericalLayout(IN_PSL)

    COMPTON_DIST = HardScatteringDistribution(PROC, MODEL, OUT_PSL)

    return @testset "om = $om" for om in OMS

        h_coords = _rand_compton_coords(el_type, RNG, om, N)
        d_coords = vec_type(h_coords)

        d_vals = vec_type(rand(RNG, el_type, N))

        h_groundtruth = RejectionSamplers._compute.(COMPTON_DIST, h_coords)

        RejectionSamplers._compute!(COMPTON_DIST, d_vals, d_coords)

        @test isapprox(Vector(d_vals), h_groundtruth)
    end
end
