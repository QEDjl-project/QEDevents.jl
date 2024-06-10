function _groundtruth_multi_rand(rng, d)
    rnd_moms = [rand(rng, SFourMomentum) for _ in 1:length(d)]
    psf_input = zip(QEDevents._particle_directions(d), QEDevents._particles(d), rnd_moms)

    return Tuple(map(x -> ParticleStateful(x...), psf_input))
end

function _groundtruth_multi_weight(dist, psfs)
    @. getE(momentum(psfs))
end
