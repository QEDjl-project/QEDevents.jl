
function _groundtruth_process_randmom(rng, d)
    n_in = number_incoming_particles(process(d))
    n_out = number_outgoing_particles(process(d))
    return Tuple(rand(rng, QEDevents._momentum_type(d), n_in)),
    Tuple(rand(rng, QEDevents._momentum_type(d), n_out))
end

function _groundtruth_process_weight(dist, psp)
    in_moms = momentum.(particles(psp, Incoming()))
    out_moms = momentum.(particles(psp, Outgoing()))
    return sum(in_moms) * sum(out_moms)
end
