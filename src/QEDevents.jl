module QEDevents

export AbstractSampler,
    AbstractScatteringProcessSampler,
    AbstractProposalSampler,
    setup,
    is_exact,
    weight,
    max_weight

export ParticleDistribution
export SingleParticleDistribution

import Random: AbstractRNG, MersenneTwister
import Distributions: rand, rand!, _rand!
using Distributions

using QEDbase
using QEDprocesses

using DocStringExtensions

include("interfaces/sampler_interface.jl")
include("interfaces/particle_distribution.jl")

include("interfaces/single_particle_distribution/types.jl")
include("interfaces/single_particle_distribution/interface.jl")

include("patch_QEDbase.jl")

end
