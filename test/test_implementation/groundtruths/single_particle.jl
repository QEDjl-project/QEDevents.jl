function _groundtruth_single_rand(rng, dist)
    rnd_mom = rand(rng, SFourMomentum)
    return ParticleStateful(
        QEDevents._particle_direction(dist), QEDevents._particle(dist), rnd_mom
    )
end

function _groundtruth_single_weight(dist, x::ParticleStateful)
    return QEDbase.getE(momentum(x))
end
