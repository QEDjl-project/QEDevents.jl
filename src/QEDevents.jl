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

using DocStringExtensions

include("interfaces/sampler_interface.jl")

end
