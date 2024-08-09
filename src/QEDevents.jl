module QEDevents

export ParticleSampleable, weight

export SingleParticleDistribution
export MultiParticleDistribution
export ScatteringProcessDistribution

import Random: AbstractRNG
import Distributions: rand, rand!, _rand!
using Distributions: Distributions

using QEDbase
using QEDcore

using DocStringExtensions

include("utils.jl")

include("interfaces/particle_distribution.jl")
include("interfaces/single_particle_distribution.jl")
include("interfaces/multi_particle_distribution.jl")
include("interfaces/process_distribution.jl")

end
