module QEDevents

export AbstractSampler,
    AbstractScatteringProcessSampler,
    AbstractProposalSampler,
    setup,
    is_exact,
    weight,
    max_weight

export UniformSampler

import Random: AbstractRNG, MersenneTwister
using Distributions
import Distributions: rand, rand!, _rand!

using QEDbase
using QEDprocesses

using DocStringExtensions

include("interfaces/sampler_interface.jl")
include("sampler/proposal/uniform.jl")
end
