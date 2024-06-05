_groundtruth_particle_type(dist) = TestParticle

function _groundtruth_single_rand(rng, dist)
    rnd_mom = rand(rng, SFourMomentum)
    return ParticleStateful(
        QEDevents._particle_direction(dist), QEDevents._particle(dist), rnd_mom
    )
end
