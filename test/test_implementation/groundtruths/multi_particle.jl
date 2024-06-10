function _groundtruth_multi_rand(rng, dist)
    rnd_moms = [rand(rng, SFourMomentum) for _ in 1:length(d)]
    return Tuple(
        map(
            x -> ParticleStateful(x...),
            zip(_particle_directions(d), _particles(d), rnd_moms),
        ),
    )
end
