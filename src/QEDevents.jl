module QEDevents

export AbstractSampler,
    AbstractScatteringProcessSampler,
    AbstractProposalSampler,
    setup,
    is_exact,
    weight,
    max_weight

import Random: rand, rand!, _rand!, AbstractRNG

using QEDbase
using QEDprocesses

include("interfaces/qedprocesses_setup_interface.jl")
include("interfaces/sampler_interface.jl")

end
