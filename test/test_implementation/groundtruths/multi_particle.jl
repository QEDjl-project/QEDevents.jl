function _groundtruth_multi_randmom(rng, d)
    return rand(rng, QEDevents._momentum_type(d), length(d))
end

function _groundtruth_multi_weight(dist, psfs)
    @. getE(momentum(psfs))
end
