
"""
replace i-th entry of t with val
"""
function tuple_setindex(t::Tuple, i, val)
    return ntuple(j -> j == i ? val : t[j], length(t))
end

_all_valid(x...) = false
_all_valid(::TestProcess, ::TestModel, ::TestPhasespaceDef) = true

function _groundtruth_multi_randmom(rng, d)
    return rand(rng, SFourMomentum, length(d))
end

function _groundtruth_multi_weight(dist, psfs)
    @. getE(momentum(psfs))
end
