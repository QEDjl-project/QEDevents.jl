
function _groundtruth_process_randmom(rng, d)
    n_in = number_incoming_particles(scattering_process(d))
    n_out = number_outgoing_particles(scattering_process(d))
    return rand(rng, SFourMomentum, n_in), rand(rng, SFourMomentum, n_out)
end

function _groundtruth_multi_weight(dist, psfs)
    @. getE(momentum(psfs))
end
