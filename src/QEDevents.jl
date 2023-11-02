module QEDevents

export AbstractSampler,
    AbstractScatteringProcessSampler,
    AbstractProposalSampler,
    setup,
    is_exact,
    weight,
    max_weight

import Random: AbstractRNG, MersenneTwister
import Distributions: rand, rand!, _rand!

using QEDbase
using QEDprocesses

using DocStringExtensions

include("interfaces/sampler_interface.jl")

end
