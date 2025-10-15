# Returns a random momentum, where all componets are uniformly distributed.
function _groundtruth_single_randmom(rng::AbstractRNG, dist)
    return rand(rng, QEDevents._momentum_type(dist))
end

function _groundtruth_single_weight(dist, x::ParticleStateful)
    return getE(momentum(x))
end
